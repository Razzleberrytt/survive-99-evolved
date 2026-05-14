local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Remotes.Net)
local Constants = require(ReplicatedStorage.Shared.Constants)
local Tuning = require(ReplicatedStorage.Shared.Config.Tuning)
local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)
local OmenService = require(script.Parent.OmenService)
local CodexService = require(script.Parent.CodexService)
local RemoteService = require(script.Parent.RemoteService)

local BeaconService = {}

local defaults = Constants.DEFAULT_BEACON
local state = {
	hp = defaults.hp,
	maxHp = defaults.maxHp,
	shield = defaults.shield,
	maxShield = defaults.maxShield,
	fuel = defaults.fuel,
	level = defaults.level,
	auraRadius = defaults.auraRadius,
	destroyed = false,

	-- Compatibility fields read by existing legacy systems until a focused cleanup PR.
	heat = 100,
	lightRadius = defaults.auraRadius,
	stability = 1,
	mods = {},
}

local initialized = false
local lastFuelMilestone = nil

local function clamp(value: number, minValue: number, maxValue: number): number
	return math.max(minValue, math.min(maxValue, value))
end

local function copyState()
	local snapshot = table.clone(state)
	snapshot.mods = table.clone(state.mods)
	return snapshot
end

local function updateDestroyed()
	state.destroyed = state.hp <= 0
end

local function publishLegacyBeaconChanged(snapshot)
	-- Legacy UI/scripts still listen to BeaconChanged. The new authoritative read-only
	-- channel for this milestone is BeaconStateChanged.
	Net.BeaconChanged:FireAllClients(snapshot)
end

function BeaconService.BroadcastState()
	local snapshot = copyState()
	local beaconChanged = RemoteService.GetEvent(RemoteNames.BeaconStateChanged)
	if beaconChanged then
		beaconChanged:FireAllClients(snapshot)
	end
	publishLegacyBeaconChanged(snapshot)
end

local function ensureBeacon()
	local beacon = workspace:FindFirstChild("Beacon")
	if not beacon then
		beacon = Instance.new("Part")
		beacon.Name = "Beacon"
		beacon.Anchored = true
		beacon.CanCollide = false
		beacon.Size = Vector3.new(4, 8, 4)
		beacon.Position = Vector3.new(0, 4, 0)
		beacon.Material = Enum.Material.Neon
		beacon.Color = Color3.fromRGB(255, 214, 120)
		beacon.Parent = workspace
	end

	CodexService.UpdateWorldState({ camp = { position = beacon.Position } })
	return beacon
end

function BeaconService.Init()
	if initialized then
		return
	end

	RemoteService.Init()
	ensureBeacon()
	updateDestroyed()
	initialized = true
	BeaconService.BroadcastState()
end

function BeaconService.GetCFrame()
	return ensureBeacon().CFrame
end

function BeaconService.GetState()
	return copyState()
end

function BeaconService.SetHealth(value: number)
	local numericValue = tonumber(value) or state.hp
	state.hp = clamp(numericValue, 0, state.maxHp)
	updateDestroyed()
	BeaconService.BroadcastState()
	return state.hp
end

function BeaconService.SetShield(value: number)
	local numericValue = tonumber(value) or state.shield
	state.shield = clamp(numericValue, 0, state.maxShield)
	BeaconService.BroadcastState()
	return state.shield
end

function BeaconService.Damage(amount: number, _source: any?)
	local remaining = math.max(tonumber(amount) or 0, 0)
	if remaining <= 0 or state.destroyed then
		return BeaconService.GetState()
	end

	local shieldDamage = math.min(state.shield, remaining)
	state.shield -= shieldDamage
	remaining -= shieldDamage

	if remaining > 0 then
		state.hp = clamp(state.hp - remaining, 0, state.maxHp)
	end

	updateDestroyed()
	BeaconService.BroadcastState()
	return BeaconService.GetState()
end

function BeaconService.Heal(amount: number, _source: any?)
	local healing = math.max(tonumber(amount) or 0, 0)
	if healing <= 0 then
		return BeaconService.GetState()
	end

	state.hp = clamp(state.hp + healing, 0, state.maxHp)
	updateDestroyed()
	BeaconService.BroadcastState()
	return BeaconService.GetState()
end

function BeaconService.ApplyFuel(amount: number)
	state.fuel = clamp(state.fuel + (tonumber(amount) or 0), 0, 100)
	CodexService.UpdateWorldState({ camp = { beaconFuel = state.fuel } })
	if state.fuel < 60 then
		CodexService.Emit("BEACON_FUEL_LOW", { fuel = state.fuel })
	end
	if state.fuel >= 95 then
		if lastFuelMilestone ~= 100 then
			lastFuelMilestone = 100
			CodexService.Emit("BEACON_FUEL_MILESTONE", { fuel = state.fuel })
		end
	else
		lastFuelMilestone = nil
	end
	BeaconService.BroadcastState()
	return state.fuel
end

local modHandlers = {
	RadiusPlus = function(enabled)
		state.auraRadius = enabled and 110 or defaults.auraRadius
		state.lightRadius = state.auraRadius
	end,
	Fortify = function(_) end,
	Siphon = function(_) end,
	Lure = function(_) end,
	Warmth = function(_) end,
	GuardianPulse = function(_) end,
}

function BeaconService.InstallMod(id: string)
	if not modHandlers[id] then
		return false
	end
	if state.mods[id] then
		return true
	end
	state.mods[id] = true
	modHandlers[id](true)
	BeaconService.BroadcastState()
	return true
end

function BeaconService.RemoveMod(id: string)
	if not state.mods[id] then
		return false
	end
	state.mods[id] = nil
	modHandlers[id](false)
	BeaconService.BroadcastState()
	return true
end

function BeaconService.OnDayStart()
	state.heat = clamp(state.heat + Constants.Beacon.HeatRecoveryPerDay, 0, 100)
	CodexService.UpdateWorldState({ camp = { beaconFuel = state.fuel } })
	BeaconService.BroadcastState()
end

function BeaconService.OnNightStart()
	local extra = 0
	if OmenService.Is("BloodMoon") then
		local omenTuning = (Tuning.get().Omen and Tuning.get().Omen.BloodMoon) or { extraFuel = 2 }
		extra = omenTuning.extraFuel or 2
	end

	state.fuel = clamp(state.fuel - (Constants.Beacon.FuelDrainPerNight + extra), 0, 100)
	Net.SpawnVFX:FireAllClients({ kind = "particle", position = BeaconService.GetCFrame().Position })
	Net.PlaySound:FireAllClients("beacon_on")
	if state.fuel <= 0 then
		Net.PlaySound:FireAllClients("beacon_off")
		warn("[Beacon] Blackout!")
		Net.BroadcastState:FireAllClients({ blackout = true })
	end
	CodexService.UpdateWorldState({ camp = { beaconFuel = state.fuel } })
	BeaconService.BroadcastState()
end

return BeaconService
