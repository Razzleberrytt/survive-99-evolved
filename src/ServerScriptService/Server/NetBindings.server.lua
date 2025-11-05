local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Throttle = require(script.Parent.Throttle)
local BuildService = require(game.ServerScriptService.Services.BuildService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local DataService = require(game.ServerScriptService.Services.DataService)
local SettingsService = require(game.ServerScriptService.Services.SettingsService)
local StoreService = require(game.ServerScriptService.Services.StoreService)
local Analytics = require(game.ServerScriptService.Services.AnalyticsAdapter)

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

local TutorialService = require(game.ServerScriptService.Services.TutorialService)
local oldFuel = Net.FuelBeacon.OnServerInvoke
Net.FuelBeacon.OnServerInvoke = function(player, amount)
	local ok, res = true, nil
	if oldFuel then ok, res = oldFuel(player, amount) end
	pcall(function() TutorialService.OnAction(player, "fuel") end)
	return ok, res
end
