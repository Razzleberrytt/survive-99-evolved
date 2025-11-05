--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local Net = require(ReplicatedStorage.Remotes.Net)

type BeaconState = Types.BeaconState

local BeaconService = {}

local state: BeaconState = {
	fuel = 100,
	heat = 100,
	lightRadius = 100,
	stability = 1,
}

local installedMods: { [string]: boolean } = {}

--// Internal helpers -------------------------------------------------------

local function publish()
	Net.BroadcastState:FireAllClients({
		beacon = state,
	})
end

--// API --------------------------------------------------------------------

function BeaconService.applyFuel(amount: number): number
	state.fuel = math.clamp(state.fuel + amount, 0, 100)
	publish()
	return state.fuel
end

function BeaconService.installMod(modId: string): boolean
	if installedMods[modId] then
		return false
	end
	installedMods[modId] = true
	-- TODO: apply mod effects (radius, regen, etc.)
	publish()
	return true
end

function BeaconService.getState(): BeaconState
	return table.clone(state)
end

function BeaconService.update(dt: number)
	-- TODO: drain fuel at night, recover heat by day.
end

return BeaconService
