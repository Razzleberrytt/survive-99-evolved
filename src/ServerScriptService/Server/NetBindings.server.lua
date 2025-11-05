local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Throttle = require(script.Parent.Throttle)
local LiveConfigAdmin = require(game.ServerScriptService.Services.LiveConfigAdmin)
local AISpawner = require(game.ServerScriptService.Services.AISpawnerService)
local BuildService = require(game.ServerScriptService.Services.BuildService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local DataService = require(game.ServerScriptService.Services.DataService)
local SettingsService = require(game.ServerScriptService.Services.SettingsService)
local StoreService = require(game.ServerScriptService.Services.StoreService)
local Analytics = require(game.ServerScriptService.Services.AnalyticsAdapter)
local TutorialService = require(game.ServerScriptService.Services.TutorialService)

-- PATCH: admin handlers (keep others intact)

Net.AdminSetConfig.OnServerInvoke = function(player, kind, key, value)
	if not LiveConfigAdmin.IsAdmin(player.UserId) then return false, "not_admin" end
	if kind == "flag" then
		return LiveConfigAdmin.SetFlag(player.UserId, key, value)
	elseif kind == "tuning" then
		return LiveConfigAdmin.SetTuning(player.UserId, key, value)
	end
	return false, "bad_kind"
end

Net.AdminAction.OnServerInvoke = function(player, action, payload)
	if not LiveConfigAdmin.IsAdmin(player.UserId) then return false, "not_admin" end
	if action == "spawn_miniboss" then
		AISpawner.spawn({ budget=1, squads={{type="Miniboss", count=1}} })
		return true
	elseif action == "spawn_wave" then
		local n = (payload and payload.night) or 5
		AISpawner.spawn({ budget=99, squads={{type="Forager",count=6},{type="Bruiser",count=3}} })
		return true
	elseif action == "fuel_plus" then
		BeaconService.ApplyFuel(20); return true
	elseif action == "blackout" then
		BeaconService.ApplyFuel(-200); return true
	elseif action == "give_shards" then
		DataService.AddShards(player, payload and payload.amount or 50); return true
	elseif action == "reset_tutorial" then
		local prof = DataService.GetProfileSnapshot(player) or DataService.LoadProfileAsync(player)
		prof.tutorialComplete = nil
		TutorialService.Begin(player)
		return true
	end
	return false, "unknown_action"
end

Net.PlaceRequest.OnServerInvoke = function(player, placeType, cfTable)
	if not Throttle.consume(player, "build", 1) then return false, "throttled" end
	local cf = CFrame.new(cfTable.X, cfTable.Y, cfTable.Z)
	local ok, reason, snapped = BuildService.ValidatePlacement(player, placeType, cf)
	if not ok then return false, reason end
	return true, BuildService.Place(player, placeType, snapped)
end

Net.RepairRequest.OnServerInvoke = function(player, targetId, amount)
	if not Throttle.consume(player, "repair", 1) then return false, "throttled" end
	return true, BuildService.Repair(player, targetId, amount)
end

Net.FuelBeacon.OnServerInvoke = function(player, amount)
	if not Throttle.consume(player, "fuel", 1) then return false, "throttled" end
	return true, BeaconService.ApplyFuel(amount or 5)
end

Net.RescueInteract.OnServerInvoke = function(player, id, action)
	local ok, res = pcall(function()
		return require(game.ServerScriptService.Services.RescueService).Interact(player, id, action)
	end)
	return ok and res or false
end

Net.GetProfile.OnServerInvoke = function(player)
	return DataService.GetProfileSnapshot(player)
end

Net.PerfPing.OnServerInvoke = function(player, tClient)
	-- return server time; client uses for RTT estimate
	return os.clock()
end

Net.ToggleSetting.OnServerInvoke = function(player, category, key, value)
	return SettingsService.Toggle(player, category, key, value)
end

-- PATCH: add purchase endpoints (optional)
Net.ToggleSetting.OnServerInvoke = Net.ToggleSetting.OnServerInvoke -- keep

if not Net.PurchaseProduct then
	local Rep = game:GetService("ReplicatedStorage")
	local Remotes = Rep:FindFirstChild("Remotes")
	local rf = Instance.new("RemoteFunction"); rf.Name = "PurchaseProduct"; rf.Parent = Remotes
	Net.PurchaseProduct = rf
end

Net.PurchaseProduct.OnServerInvoke = function(player, key)
	Analytics.PurchaseAttempt(player, key)
	local policy = StoreService.CanOffer(player)
	if not policy.allowIAP then
		Analytics.PurchaseResult(player, key, false)
		return false, "iap_blocked"
	end
	local ok, err = StoreService.PurchaseDevProduct(player, key)
	Analytics.PurchaseResult(player, key, ok and true or false)
	return ok, err
end

local oldFuel = Net.FuelBeacon.OnServerInvoke
Net.FuelBeacon.OnServerInvoke = function(player, amount)
	local ok, res = true, nil
	if oldFuel then ok, res = oldFuel(player, amount) end
	pcall(function() TutorialService.OnAction(player, "fuel") end)
	return ok, res
end
