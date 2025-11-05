local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Matter = require(ReplicatedStorage.Packages.matter)

local world = Matter.World.new()

local systemsFolder = ReplicatedStorage:WaitForChild("Systems")
local systemFns = {
	require(systemsFolder.S_ThreatMap),
	require(systemsFolder.S_AISquadBrain),
	require(systemsFolder.S_StructureDamage),
	require(systemsFolder.S_Trap),
	require(systemsFolder.S_BeaconAura),
	require(systemsFolder.S_Cleanup),
}

local servicesFolder = script.Parent.Parent:WaitForChild("Services")
local GameService = require(servicesFolder.GameService)

GameService.start(world)

RunService.Stepped:Connect(function(_, dt)
	for _, sys in ipairs(systemFns) do
		sys(world, dt)
	end
end)
