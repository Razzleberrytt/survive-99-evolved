local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Throttle = require(script.Parent.Throttle)
local BuildService = require(game.ServerScriptService.Services.BuildService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)

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
