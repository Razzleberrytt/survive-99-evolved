local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")

local Net = require(Rep.Remotes.Net)
local C = require(Rep.Shared.Constants)
local WavePlanner = require(Rep.Shared.WavePlanner)
local AISpawner = require(game.ServerScriptService.Services.AISpawnerService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local AtmosphereService = require(script.Parent.AtmosphereService)

local M = {}
local state = { night = 0, phase = "Lobby", omen = nil }

local worldRef = nil

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
	worldRef = world
	state.phase = "Day"
	state.omen = nil
	broadcast()
end

function M.startDay(world)
	state.phase = "Day"; state.omen = nil
	local RescueService = require(script.Parent.RescueService)
	RescueService.GenerateDailyRescues()
	BeaconService.OnDayStart()
	AtmosphereService.OnOmenEnd()
	broadcast()
end

function M.startNight(world)
	if world then
		worldRef = world
	end
	state.phase = "Night"; state.night += 1
	state.omen = rollOmen()
	AtmosphereService.OnOmenStart(state.omen)
	if state.omen then Net.PlaySound:FireAllClients("omen") end
	BeaconService.OnNightStart()
	local plan = WavePlanner(state.night, #Players:GetPlayers(), state.omen)
	-- Simple miniboss flag on milestone nights
	if state.night % 5 == 0 then table.insert(plan.squads, {type="Miniboss", count=1}) end
	AISpawner.spawn(plan)
	broadcast()
	pcall(function()
		local TutorialService = require(script.Parent.TutorialService)
		for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
			TutorialService.OnAction(plr, "start")
		end
	end)
end

function M.requestNightStart(_player)
	if state.phase ~= "Day" then
		return false, "not_day"
	end
	M.startNight(worldRef)
	return true
end

return M
