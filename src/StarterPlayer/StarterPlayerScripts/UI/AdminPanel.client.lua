local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

-- Show only if you are whitelisted on server (admins list)
local adminOk = false

local function rpcCheck()
	-- Piggyback by trying a no-op admin action
	local ok, res = pcall(function()
		return Net.AdminAction:InvokeServer({ action = "_probe" })
	end)
	-- If server rejects non-admin, we treat as false; otherwise panel shows
	adminOk = ok and (res ~= false)
end
pcall(rpcCheck)

if not adminOk then return end

local gui = Instance.new("ScreenGui")
gui.Name = "AdminPanel"; gui.ResetOnSpawn = false; gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

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

local function mkButton(y, txt, cb)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(0, 140, 0, 28)
	b.Position = UDim2.new(0, 8, 0, y)
	b.Text = txt; b.Parent = frame
	b.MouseButton1Click:Connect(function() pcall(cb) end)
	return b
end

mkLabel(8, "Admin Panel")

mkButton(36, "Spawn Miniboss", function()
	Net.AdminAction:InvokeServer({ action = "spawn_miniboss" })
end)
mkButton(70, "Spawn Wave", function()
	Net.AdminAction:InvokeServer({ action = "spawn_wave", payload = { night = 5 } })
end)
mkButton(104, "+20 Fuel", function()
	Net.AdminAction:InvokeServer({ action = "fuel_plus" })
end)
mkButton(138, "Blackout Beacon", function()
	Net.AdminAction:InvokeServer({ action = "blackout" })
end)
mkButton(172, "Give 50 Shards", function()
	Net.AdminAction:InvokeServer({ action = "give_shards", payload = { amount = 50 } })
end)
mkButton(206, "Reset Tutorial", function()
	Net.AdminAction:InvokeServer({ action = "reset_tutorial" })
end)

-- Flags/Tuning quick toggles
local toggle = Instance.new("TextButton")
toggle.Size = UDim2.new(0, 140, 0, 28)
toggle.Position = UDim2.new(0, 168, 0, 36)
toggle.Text = "softLaunch OFF"
toggle.Parent = frame
toggle.MouseButton1Click:Connect(function()
	Net.AdminSetConfig:InvokeServer({ kind = "flag", key = "softLaunch", value = false })
	toggle.Text = "softLaunch OFF"
end)

local tuning = Instance.new("TextButton")
tuning.Size = UDim2.new(0, 140, 0, 28)
tuning.Position = UDim2.new(0, 168, 0, 70)
tuning.Text = "waveCap=80"
tuning.Parent = frame
tuning.MouseButton1Click:Connect(function()
	Net.AdminSetConfig:InvokeServer({ kind = "tuning", key = "waveCap", value = 100 })
	tuning.Text = "waveCap=100"
end)
