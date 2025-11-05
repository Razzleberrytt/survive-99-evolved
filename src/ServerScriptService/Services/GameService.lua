--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Remotes.Net)
local WavePlanner = require(ReplicatedStorage.Shared.WavePlanner)

local AISpawnerService = require(script.Parent.AISpawnerService)
local RescueService = require(script.Parent.RescueService)

type MatterWorld = typeof(require(ReplicatedStorage.Packages.matter).World.new())

local GameService = {}

local state = {
	phase = "Lobby",
	night = 0,
	omen = nil :: string?,
	world = nil :: MatterWorld?,
}

local function broadcast()
	Net.BroadcastState:FireAllClients({
		night = state.night,
		phase = state.phase,
		omen = state.omen,
	})
end

--// Lifecycle

function GameService.start(world: MatterWorld)
	state.world = world
	Net.NightStartVote.OnServerEvent:Connect(function(player: Player)
		if state.phase == "Day" then
			GameService.startNight()
		end
	end)
	GameService.startDay()
end

function GameService.startDay()
	state.phase = "Day"
	-- TODO: Enable building, schedule rescues, heal beacon heat.
	RescueService.generateDailyRescues()
	broadcast()
end

function GameService.startNight()
	state.phase = "Night"
	state.night += 1
	-- TODO: Roll omen & notify clients.
	local plan = WavePlanner(state.night, #Players:GetPlayers())
	AISpawnerService.spawn(plan)
	broadcast()
end

function GameService.getState()
	return {
		phase = state.phase,
		night = state.night,
		omen = state.omen,
	}
end

return GameService
