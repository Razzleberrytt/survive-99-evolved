local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

local AdminRemote = Net.Admin_Perform
if not AdminRemote then
  return
end

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
  return
end

-- Show only if you are whitelisted on server (admins list)
local adminOk = false

local function perform(action, payload)
  local ok, result, extra = pcall(function()
    return AdminRemote:InvokeServer({ action = action, payload = payload })
  end)
  if not ok then
    warn("[AdminPanel] remote failed", result)
    return false
  end
  if result ~= true then
    if extra then
      warn(string.format("[AdminPanel] action %s denied: %s", action, tostring(extra)))
    end
    return false
  end
  return true
end

local function rpcCheck()
  adminOk = perform("_probe")
end
pcall(rpcCheck)

if not adminOk then
  return
end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 320, 0, 280)
frame.Position = UDim2.new(1, -332, 0, 48)
frame.BackgroundTransparency = 0.15
frame.Parent = gui

local function mkLabel(y, txt)
  local t = Instance.new("TextLabel")
  t.Size = UDim2.new(1, -16, 0, 22)
  t.Position = UDim2.new(0, 8, 0, y)
  t.BackgroundTransparency = 1
  t.TextXAlignment = Enum.TextXAlignment.Left
  t.Font = Enum.Font.Gotham
  t.TextSize = 14
  t.Text = txt
  t.Parent = frame
  return t
end

local function mkButton(y, txt, action, payload)
  local b = Instance.new("TextButton")
  b.Size = UDim2.new(0, 140, 0, 28)
  b.Position = UDim2.new(0, 8, 0, y)
  b.Text = txt
  b.Parent = frame
  b.MouseButton1Click:Connect(function()
    perform(action, payload)
  end)
  return b
end

mkLabel(8, "Admin Panel")

mkButton(36, "Spawn Miniboss", "spawn_miniboss")
mkButton(70, "Spawn Wave", "spawn_wave")
mkButton(104, "+20 Fuel", "fuel_plus", { amount = 20 })
mkButton(138, "Blackout Beacon", "blackout")
mkButton(172, "Give 50 Shards", "give_shards", { amount = 50 })
mkButton(206, "Reset Tutorial", "reset_tutorial")

-- Flags/Tuning quick toggles
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 140, 0, 28)
toggle.Position = UDim2.new(0, 168, 0, 36)
toggle.Text = "softLaunch OFF"
toggle.Parent = frame
toggle.MouseButton1Click:Connect(function()
  if perform("set_flag", { key = "softLaunch", value = false }) then
    toggle.Text = "softLaunch OFF"
  end
end)

local tuning = Instance.new("TextButton")
tuning.Size = UDim2.new(0, 140, 0, 28)
tuning.Position = UDim2.new(0, 168, 0, 70)
tuning.Text = "waveCap=80"
tuning.Parent = frame
tuning.MouseButton1Click:Connect(function()
  if perform("set_tuning", { key = "waveCap", value = 100 }) then
    tuning.Text = "waveCap=100"
  end
end)
