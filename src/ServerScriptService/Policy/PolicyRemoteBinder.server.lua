local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local PolicyGuard = require(script.Parent:WaitForChild("PolicyGuard"))
local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PolicyRemote"))

Remotes.GetPolicyFlags.OnServerInvoke = function(player)
  -- Server-authoritative: client uses this only to hide UI.
  local allowed = PolicyGuard.canMonetize(player)
  return {
    monetizationAllowed = allowed,
  }
end

-- Defensive: if a non-player somehow calls, return deny.
game:FindFirstChildWhichIsA("RunService").Heartbeat:Connect(function() end)
