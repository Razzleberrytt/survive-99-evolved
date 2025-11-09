local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local C = require(Rep.Shared.Constants)
local Tuning = require(Rep.Shared.Config.Tuning)
local OmenService = require(script.Parent.OmenService)
local CodexService = require(script.Parent.CodexService)

local M = {}
local state = { fuel = 100, heat = 100, lightRadius = 90, stability = 1, mods = {} }
local function clamp(x, a, b) return math.max(a, math.min(b, x)) end
local function fire() Net.BeaconChanged:FireAllClients(table.freeze(table.clone(state))) end
local lastFuelMilestone = nil

-- world beacon instance (simple Part if none)
local function ensureBeacon()
	local b = workspace:FindFirstChild("Beacon")
        if not b then
                b = Instance.new("Part")
                b.Name = "Beacon"; b.Anchored = true; b.CanCollide = false; b.Size = Vector3.new(4,8,4)
                b.Position = Vector3.new(0,4,0); b.Material = Enum.Material.Neon
                b.Color = Color3.fromRGB(255, 214, 120); b.Parent = workspace
        end
        CodexService.UpdateWorldState({ camp = { position = b.Position } })
        return b
end

function M.GetCFrame() return ensureBeacon().CFrame end
function M.GetState() return state end
function M.ApplyFuel(n)
        state.fuel = clamp(state.fuel + (n or 0), 0, 100)
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
        fire()
        return state.fuel
end

local modHandlers = {
	RadiusPlus = function(en) state.lightRadius = en and 110 or 90 end,
	Fortify   = function(_)  end, -- handled by BuildService reading this mod
	Siphon    = function(_)  end, -- handled in AI death hooks (future)
	Lure      = function(_)  end,
	Warmth    = function(_)  end,
	GuardianPulse = function(_) end,
}

function M.InstallMod(id)
	if not modHandlers[id] then return false end
	if state.mods[id] then return true end
	state.mods[id] = true; modHandlers[id](true); fire(); return true
end

function M.RemoveMod(id)
	if not state.mods[id] then return false end
	state.mods[id] = nil; modHandlers[id](false); fire(); return true
end

-- Day/Night hooks
function M.OnDayStart()
        state.heat = clamp(state.heat + C.Beacon.HeatRecoveryPerDay, 0, 100)
        CodexService.UpdateWorldState({ camp = { beaconFuel = state.fuel } })
        fire()
end

function M.OnNightStart()
  local extra = 0
  if OmenService.Is("BloodMoon") then
    local O = (Tuning.get().Omen and Tuning.get().Omen.BloodMoon) or { extraFuel = 2 }
    extra = O.extraFuel or 2
  end
  state.fuel = clamp(state.fuel - (C.Beacon.FuelDrainPerNight + extra), 0, 100)
        Net.SpawnVFX:FireAllClients({ kind="particle", position = M.GetCFrame().Position })
        Net.PlaySound:FireAllClients("beacon_on")
        if state.fuel <= 0 then
                Net.PlaySound:FireAllClients("beacon_off")
                warn("[Beacon] Blackout!")
                Net.BroadcastState:FireAllClients({ blackout = true })
        end
        CodexService.UpdateWorldState({ camp = { beaconFuel = state.fuel } })
        fire()
end

return M
