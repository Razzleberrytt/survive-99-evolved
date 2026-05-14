local GameConfig = require(game.ReplicatedStorage.Shared.Config.Game)

local FOLDER_NAME = "SpawnPoints"
local RINGS = {
	Near = { radius = 90, count = 14 },
	Mid = { radius = 140, count = 18 },
	Far = { radius = 195, count = 10 },
}

local function folder()
	local f = workspace:FindFirstChild(FOLDER_NAME)
	if not f then
		f = Instance.new("Folder")
		f.Name = FOLDER_NAME
		f.Parent = workspace
	end
	return f
end

local function ensureMapSpawns()
	local f = folder()
	if #f:GetChildren() > 0 then return f end
	for name, cfg in pairs(RINGS) do
		for i = 1, cfg.count do
			local angle = (i / cfg.count) * math.pi * 2 + math.rad((#name * 11) % 30)
			local marker = Instance.new("Part")
			marker.Name = "EnemySpawn_" .. name
			marker.Anchored = true
			marker.CanCollide = false
			marker.Transparency = 1
			marker.Size = Vector3.new(3, 1, 3)
			marker.Position = Vector3.new(math.cos(angle) * cfg.radius, 0, math.sin(angle) * cfg.radius)
			marker:SetAttribute("Ring", name)
			marker.Parent = f
		end
	end
	return f
end

local function pickSpawn(kind)
	local enemy = GameConfig.Enemies[kind] or GameConfig.Enemies.Forager
	local wantedRing = enemy.ring or "Mid"
	local candidates = {}
	for _, part in ipairs(ensureMapSpawns():GetChildren()) do
		if part:GetAttribute("Ring") == wantedRing then table.insert(candidates, part) end
	end
	local marker = candidates[math.random(1, math.max(#candidates, 1))] or ensureMapSpawns():GetChildren()[1]
	local offset = Vector3.new(math.random(-8, 8), 2, math.random(-8, 8))
	return marker.Position + offset
end

local function spawnEnemy(kind)
	local cfg = GameConfig.Enemies[kind] or GameConfig.Enemies.Forager
	local part = Instance.new("Part")
	part.Name = "Enemy_" .. kind
	part.Size = kind == "Miniboss" and Vector3.new(4, 6, 4) or Vector3.new(2, 3, 2)
	part.Position = pickSpawn(kind)
	part.Color = kind == "Miniboss" and Color3.fromRGB(170, 0, 0) or Color3.fromRGB(200, 60, 60)
	part:SetAttribute("Kind", kind)
	part:SetAttribute("HP", cfg.hp)
	part:SetAttribute("Damage", cfg.damage)
	part:SetAttribute("Speed", cfg.speed)
	part.Parent = workspace
	return part
end

return function(_world, plan)
	local spawned = {}
	for _, squad in ipairs((plan and plan.squads) or {}) do
		for _ = 1, squad.count do
			table.insert(spawned, spawnEnemy(squad.type))
		end
	end
	return spawned
end
