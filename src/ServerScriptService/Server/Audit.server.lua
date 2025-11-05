local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local PhysicsService = game:GetService("PhysicsService")
local Rep = game:GetService("ReplicatedStorage")

local function p(msg) print("[AUDIT] "..msg) end
local function pass(name) p("✅ "..name) end
local function fail(name, why) warn("[AUDIT] ❌ "..name.." -> "..tostring(why)) end

local function exists(inst, name) return inst:FindFirstChild(name) ~= nil end

local function checkStreaming()
	local ok = pcall(function() return workspace.StreamingEnabled end) and workspace.StreamingEnabled
	if ok then pass("StreamingEnabled") else fail("StreamingEnabled","off") end
	return ok
end

local function checkReplicatedFolders()
	local ok = true
	for _, path in ipairs({"Remotes","Components","Systems","Shared","Tests"}) do
		if exists(Rep, path) then pass("ReplicatedStorage."..path) else ok=false; fail("ReplicatedStorage."..path,"missing") end
	 end
	return ok
end

local function checkRemotes()
	local Net = require(Rep.Remotes.Net)
	local required = {
		"PlaceRequest","RepairRequest","FuelBeacon","RescueInteract","GetProfile",
		"NightStartVote","BroadcastState","BeaconChanged","SpawnVFX","TutorialEvent",
		"PlaySound","ToggleSetting","PerfPing","AdminAction","AdminSetConfig"
	}
	local ok = true
	for _, k in ipairs(required) do
		if Net[k] then pass("Remote "..k) else ok=false; fail("Remote "..k,"missing") end
	end
	return ok
end

local function checkSystems()
	local ok = true
	local Systems = Rep:FindFirstChild("Systems")
	local needed = {
		"S_ThreatMap","S_AISquadBrain","S_PathfindAI","S_MoveAI","S_EnemyAttack",
		"S_BossAbilities","S_Trap","S_BeaconAura","S_HealthDeath","S_Cleanup"
	}
	for _, s in ipairs(needed) do
		if Systems and Systems:FindFirstChild(s) then
			local good = pcall(function() require(Systems[s]) end)
			if good then pass("System "..s) else ok=false; fail("System "..s,"require error") end
		else ok=false; fail("System "..s,"missing") end
	end
	return ok
end

local function checkActors()
	local SSS = game:GetService("ServerScriptService")
	local folder = SSS:FindFirstChild("Actors")
	local count = 0
	if folder then
		for _, ch in ipairs(folder:GetChildren()) do if ch:IsA("Actor") then count += 1 end end
	end
	if count >= 1 then pass(("Actors present (%d)"):format(count)) else fail("Actors","none") end
	return count >= 1
end

local function checkPhysicsGroups()
	local ok = true
	local function try(fn, ...) local s, e = pcall(fn, ...); return s, e end
	local groups = {"Players","Enemies","Placeables","Traps"}
	for _, g in ipairs(groups) do try(PhysicsService.CreateCollisionGroup, PhysicsService, g) end
	local pairsToCheck = {
		{"Players","Enemies", true},
		{"Players","Placeables", true},
		{"Enemies","Placeables", true},
		{"Traps","Players", false},
	}
	for _, row in ipairs(pairsToCheck) do
		local s = try(PhysicsService.CollisionGroupSetCollidable, PhysicsService, row[1], row[2], row[3])
		if s then pass(("Collision %s↔%s"):format(row[1],row[2]))
		else ok=false; fail(("Collision %s↔%s"):format(row[1],row[2]),"set failed") end
	end
	return ok
end

local function checkLiveConfig()
	local ok = true
	local LiveConfig = require(game.ServerScriptService.Services.LiveConfigService)
	local Tuning = LiveConfig and LiveConfig.Tuning
	if Tuning and Tuning.get and type(Tuning.get()) == "table" then pass("LiveConfig/Tuning accessible")
	else ok=false; fail("LiveConfig/Tuning","unavailable") end
	return ok
end

local function checkDataService()
	local ok = true
	local Data = require(game.ServerScriptService.Services.DataService)
	for _, plr in ipairs(Players:GetPlayers()) do
		local prof = Data.GetProfileSnapshot(plr) or Data.LoadProfileAsync(plr)
		if prof and prof.currencies and prof.currencies.shards ~= nil then
			pass(("Data profile for %s"):format(plr.Name))
		else ok=false; fail("Data profile","missing fields") end
	end
	if #Players:GetPlayers() == 0 then pass("DataService (no players to verify)") end
	return ok
end

local function heartbeatProbe(seconds)
	local hb = game:GetService("RunService").Heartbeat
	local maxDt, sum, n = 0, 0, 0
	local t0 = os.clock()
	local conn; conn = hb:Connect(function(dt)
		maxDt = math.max(maxDt, dt); sum += dt; n += 1
	end)
	task.wait(seconds)
	conn:Disconnect()
	local avg = (n > 0) and (sum/n) or 0
	p(("Perf: avg %.1f ms | max %.1f ms over %.1fs"):format(avg*1000, maxDt*1000, seconds))
	return true
end

local function runAudit()
	p("=== AUDIT START ===")
	local ok = true
	ok = checkStreaming() and ok
	ok = checkReplicatedFolders() and ok
	ok = checkRemotes() and ok
	ok = checkSystems() and ok
	ok = checkActors() and ok
	ok = checkPhysicsGroups() and ok
	ok = checkLiveConfig() and ok
	ok = checkDataService() and ok
	heartbeatProbe(2.0)
	if ok then p("=== ✅ AUDIT PASS ===") else p("=== ❌ AUDIT FAIL (see above) ===") end
end

-- chat command
Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		if msg:lower():match("^/audit") then runAudit() end
	end)
end)

return {}
