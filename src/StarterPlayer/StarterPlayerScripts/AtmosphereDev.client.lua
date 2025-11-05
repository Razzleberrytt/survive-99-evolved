local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

Players.LocalPlayer.Chatted:Connect(function(msg)
  local preset = msg:match("^/mood%s+(%w+)$")
  if preset then
    require(Rep.Shared.Config.Atmosphere).current = preset
    Net.BroadcastState:FireServer() -- harmless nudge; server already pushes on real changes
    -- Locally apply immediately (client-side)
    local apply = require(Rep.Shared.Config.Atmosphere)
    -- No-op; AtmosphereClient listens on BroadcastState and on load.
  end
  if msg:lower() == "/preset" then
    print("[Preset] Current:", require(Rep.Shared.Config.Atmosphere).current)
  end
end)
