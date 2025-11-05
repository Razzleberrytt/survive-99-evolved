local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Matter = require(ReplicatedStorage.Packages.matter)
local WorldRegistry = require(ReplicatedStorage.Shared.WorldRegistry)

local World = Matter.World.new()
WorldRegistry.set(World)

local Systems = ReplicatedStorage.Systems
local systemFns = {
	require(Systems.S_ThreatMap),
	require(Systems.S_AISquadBrain),
	require(Systems.S_PathfindAI),
	require(Systems.S_MoveAI),
	require(Systems.S_EnemyAttack),
	require(Systems.S_BossAbilities),
	require(Systems.S_Trap),
	require(Systems.S_BeaconAura),
	require(Systems.S_HealthDeath),
	require(Systems.S_Cleanup),
}

local ServicesFolder = script.Parent.Parent:WaitForChild("Services")
local NavVolumeService = require(ServicesFolder.NavVolumeService)
NavVolumeService.Bootstrap()
local LiveConfig = require(ServicesFolder.LiveConfigService)
LiveConfig.Start()
local BugReport = require(ServicesFolder.BugReportService)
BugReport.Start()
local GameService = require(ServicesFolder.GameService)
local DataService = require(ServicesFolder.DataService)
local BeaconService = require(ServicesFolder.BeaconService)
local TutorialService = require(ServicesFolder.TutorialService)

game.Players.PlayerAdded:Connect(function(plr)
	DataService.LoadProfileAsync(plr)
	TutorialService.Begin(plr)
end)
game.Players.PlayerRemoving:Connect(function(plr) DataService.SaveProfileAsync(plr) end)

GameService.start(World)

RunService.Stepped:Connect(function(_, dt)
	for _, sys in systemFns do sys(World, dt) end
end)

-- Ensure beacon UI gets an initial push
task.delay(0.5, function() local s = BeaconService.GetState and BeaconService.GetState() if s then require(ReplicatedStorage.Remotes.Net).BeaconChanged:FireAllClients(s) end end)
