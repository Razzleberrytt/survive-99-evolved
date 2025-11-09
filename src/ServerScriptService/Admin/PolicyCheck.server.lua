local Players = game:GetService("Players")
local Admin = require(script.Parent:WaitForChild("Admin"):WaitForChild("Access"))
local Telemetry = require(script.Parent.Parent:WaitForChild("Ops"):WaitForChild("Telemetry"))
local PolicyGuard = require(script.Parent.Parent:WaitForChild("Policy"):WaitForChild("PolicyGuard"))

local function onChat(player, message)
  if message == "/policycheck" then
    if not Admin.isAdmin(player.UserId) then
      Telemetry.log("soft_gate_blocked", { userId = player.UserId, cmd = message })
      return
    end
    local allowed = PolicyGuard.canMonetize(player)
    Telemetry.log("policy_check", { userId = player.UserId, monetizationAllowed = allowed })
  end
end

Players.PlayerChatted:Connect(onChat)
