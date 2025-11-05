--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Net = require(ReplicatedStorage.Remotes.Net)

local BuildService = {}

--// Validation --------------------------------------------------------------

function BuildService.validatePlacement(player: Player, buildType: string, cf: CFrame)
	-- TODO: grid snap, distance, collision, LOS checks.
	return true, nil
end

function BuildService.place(player: Player, buildType: string, cf: CFrame)
	local ok, reason = BuildService.validatePlacement(player, buildType, cf)
	if not ok then
		return false, reason
	end
	-- TODO: instantiate server object and attach components via Matter.
	return true, "placeholder-id"
end

function BuildService.repair(player: Player, target: Instance, amount: number)
	-- TODO: resource spend + health component mutation.
	return 0
end

return BuildService
