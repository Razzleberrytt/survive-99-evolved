local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local Remotes = require(ReplicatedStorage:WaitForChild("Remotes"):WaitForChild("PolicyRemote"))

local ok, flags = pcall(function()
  return Remotes.GetPolicyFlags:InvokeServer()
end)

local allowed = ok and flags and flags.monetizationAllowed == true

-- Soft guard: hide purchase UI if not allowed.
local function hideShop()
  -- Adapt these to your UI names if different:
  local screenGui = player:WaitForChild("PlayerGui", 10)
  if not screenGui then return end
  local shop = screenGui:FindFirstChild("ShopGui", true)
  if shop then shop.Enabled = false end

  -- Show a friendly message if you have a placeholder label:
  local msg = screenGui:FindFirstChild("ShopNotAvailableLabel", true)
  if msg and msg:IsA("TextLabel") then
    msg.Visible = true
  end
end

if not allowed then
  hideShop()
end
