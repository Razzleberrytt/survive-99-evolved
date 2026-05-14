local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)
local RemoteService = require(script.Parent.RemoteService)

local PhaseService = {}

local PHASES = Constants.PHASES
local PHASE_ORDER = {
	PHASES.LOBBY,
	PHASES.DAY,
	PHASES.DUSK,
	PHASES.NIGHT,
	PHASES.DAWN,
}

local DEV_FAST_PHASES = false
local DEV_PHASE_DURATIONS = {
	[PHASES.LOBBY] = 3,
	[PHASES.DAY] = 10,
	[PHASES.DUSK] = 3,
	[PHASES.NIGHT] = 10,
	[PHASES.DAWN] = 3,
}

local initialized = false
local running = false
local loopToken = 0

local state = {
	phase = PHASES.LOBBY,
	night = 0,
	phaseStartedAt = 0,
	duration = Constants.PHASE_DURATIONS[PHASES.LOBBY],
	endsAt = 0,
	omen = nil,
}

local function now(): number
	return workspace:GetServerTimeNow()
end

local function getDuration(phase: string): number
	local durations = DEV_FAST_PHASES and DEV_PHASE_DURATIONS or Constants.PHASE_DURATIONS
	return durations[phase] or 10
end

local function copyState()
	return table.clone(state)
end

local function phaseIndex(phase: string): number
	for index, phaseName in ipairs(PHASE_ORDER) do
		if phaseName == phase then
			return index
		end
	end
	return 1
end

local function enterPhase(phase: string)
	local timestamp = now()
	state.phase = phase
	state.phaseStartedAt = timestamp
	state.duration = getDuration(phase)
	state.endsAt = timestamp + state.duration
	state.omen = nil

	-- The night number labels the upcoming/current survival night. It becomes 1
	-- when the first Day starts, then increments after each Dawn as the next Day starts.
	if phase == PHASES.DAY then
		state.night += 1
	end
end

function PhaseService.BroadcastState()
	local phaseChanged = RemoteService.GetEvent(RemoteNames.PhaseStateChanged)
	if phaseChanged then
		phaseChanged:FireAllClients(copyState())
	end
end

function PhaseService.Init()
	if initialized then
		return
	end

	RemoteService.Init()
	enterPhase(PHASES.LOBBY)
	initialized = true
	PhaseService.BroadcastState()
end

function PhaseService.Start()
	if running then
		return
	end

	if not initialized then
		PhaseService.Init()
	end

	running = true
	loopToken += 1
	local token = loopToken
	PhaseService.BroadcastState()

	task.spawn(function()
		while running and token == loopToken do
			local timestamp = now()
			if timestamp >= state.endsAt then
				PhaseService.AdvancePhase()
			else
				-- Lightweight read-only countdown updates for the MVP HUD, capped at once per second.
				PhaseService.BroadcastState()
			end
			task.wait(1)
		end
	end)
end

function PhaseService.Stop()
	if not running then
		return
	end

	running = false
	loopToken += 1
end

function PhaseService.GetState()
	return copyState()
end

function PhaseService.AdvancePhase()
	local currentIndex = phaseIndex(state.phase)
	local nextIndex = currentIndex + 1
	if nextIndex > #PHASE_ORDER then
		nextIndex = 2 -- After Dawn, continue with Day; Lobby only happens at server start.
	end

	enterPhase(PHASE_ORDER[nextIndex])
	PhaseService.BroadcastState()
	return PhaseService.GetState()
end

return PhaseService
