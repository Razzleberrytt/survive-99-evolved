local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Config = require(Rep.Shared.Config.Atmosphere)

local M = {}
local state = { preset = Config.current, omen = nil }

local function push()
  Net.BroadcastState:FireAllClients({ atmospherePreset = state.preset, omen = state.omen })
end

function M.SetPreset(name)
  if Config.Presets[name] then
    state.preset = name
    push()
    return true
  end
  return false
end

function M.OnOmenStart(omen)
  state.omen = omen
  push()
end

function M.OnOmenEnd()
  state.omen = nil
  push()
end

return M
