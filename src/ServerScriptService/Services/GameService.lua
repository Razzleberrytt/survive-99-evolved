local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Remotes.Net)
local C = require(Rep.Shared.Constants)
local WavePlanner = require(Rep.Shared.WavePlanner)
local AISpawner = require(game.ServerScriptService.Services.AISpawnerService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)

local M = {}
local state = { night = 0, phase = "Lobby", omen = nil }

local function broadcast()
	Net.BroadcastState:FireAllClients({
		night = state.night,
		phase = state.phase,
		omen = state.omen,
	})
end

local function rollOmen()
	local r = math.random()
	local acc = 0
	for k, w in pairs(C.OmenChances) do
		acc += w
		if r <= acc then return k end
	end
	return nil
end

function M.start(world)
	state.phase = "Day"; state.omen = nil
	broadcast()
	Net.NightStartVote.OnServerEvent:Connect(function(_player)
		if state.phase == "Day" then M.startNight(world) end
	end)
end

function M.startDay(world)
	state.phase = "Day"; state.omen = nil
	BeaconService.OnDayStart()
	broadcast()
end

function M.startNight(world)
	state.phase = "Night"; state.night += 1
	state.omen = rollOmen()
	BeaconService.OnNightStart()
	local plan = WavePlanner(state.night, #Players:GetPlayers(), state.omen)
	-- Simple miniboss flag on milestone nights
	if state.night % 5 == 0 then table.insert(plan.squads, {type="Miniboss", count=1}) end
	AISpawner.spawn(plan)
	broadcast()
end

return M
