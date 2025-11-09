local Players = game:GetService("Players")
local Admin = require(script.Parent:WaitForChild("Admin"):WaitForChild("Access"))
local Telemetry = require(script.Parent.Parent:WaitForChild("Ops"):WaitForChild("Telemetry"))
local NavPresets = require(script.Parent.Parent:WaitForChild("Nav"):WaitForChild("NavPresets"))

local function onChat(player, message)
  if message == "/navpreset base-safe" then
    if not Admin.isAdmin(player.UserId) then
      Telemetry.log("soft_gate_blocked", { userId = player.UserId, cmd = message })
      return
    end
    local ok = NavPresets.applyBaseSafe()
    Telemetry.log("navpreset_apply", { userId = player.UserId, preset = "base-safe", ok = ok })
  end
end

Players.PlayerChatted:Connect(onChat)
