--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)

local AISpawnerService = {}

function AISpawnerService.spawn(plan)
	-- TODO: instantiate squads, respect NPC cap, queue overflow.
end

return AISpawnerService
