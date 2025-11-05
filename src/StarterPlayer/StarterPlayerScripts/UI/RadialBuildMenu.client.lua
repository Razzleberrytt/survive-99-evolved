local Rep = game:GetService("ReplicatedStorage")
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Net = require(Rep.Remotes.Net)
local VFX = require(Rep.Shared.VFX)

local player = Players.LocalPlayer
local gui = Instance.new("ScreenGui")
gui.Name = "RadialBuild"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")

local center = Instance.new("Frame")
center.AnchorPoint = Vector2.new(0.5,0.5)
center.Position = UDim2.fromScale(0.5,0.7)
center.Size = UDim2.fromOffset(220,220)
center.BackgroundTransparency = 0.35
center.Visible = false
center.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,24)
title.Position = UDim2.new(0,0,0,0)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Build"
title.Parent = center

local options = {
	{key="Wall", label="Wall"},
	{key="TrapSpike", label="Spike"},
	{key="SlowTotem", label="Slow"},
	{key="Lantern", label="Lantern"},
	{key="Door", label="Door"},
}
local current = nil

local function makeOption(i, total, text, key)
	local angle = (i-1)/total * math.pi*2
	local r = 80
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(80,32)
	btn.Position = UDim2.fromOffset(110 + math.cos(angle)*r - 40, 110 + math.sin(angle)*r - 16)
	btn.Text = text
	btn.Parent = center
	btn.MouseButton1Click:Connect(function()
		current = key
		title.Text = "Build: "..text.." (tap world)"
	end)
end

for i, opt in ipairs(options) do makeOption(i, #options, opt.label, opt.key) end

-- Toggle button in HUD if present; else create a small button
local toggle = Instance.new("TextButton")
toggle.Name = "OpenBuild"
toggle.Text = "Build"
toggle.Size = UDim2.fromOffset(100,40)
toggle.Position = UDim2.new(0, 12, 1, -100)
toggle.AnchorPoint = Vector2.new(0,1)
toggle.BackgroundTransparency = 0.2
toggle.Parent = gui
toggle.MouseButton1Click:Connect(function()
	center.Visible = not center.Visible
end)

-- Place by tapping world
local function screenTapToWorld(pos: Vector2)
	local cam = workspace.CurrentCamera
	local ray = cam:ViewportPointToRay(pos.X, pos.Y)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
	local hit = workspace:Raycast(ray.Origin, ray.Direction*500, raycastParams)
	if hit then
		return CFrame.new(hit.Position)
	end
	return nil
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if not center.Visible or not current then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		local pos = (input.UserInputType == Enum.UserInputType.Touch) and input.Position or UIS:GetMouseLocation()
		local cf = screenTapToWorld(pos)
		if cf then
			local ok, result = Net.PlaceRequest:InvokeServer(current, {X=cf.X, Y=cf.Y, Z=cf.Z})
			if not ok then
				title.Text = "Blocked: "..tostring(result)
				VFX.spawnRingBurst(cf.Position, Color3.fromRGB(255,100,100), 0.6)
			else
				VFX.spawnRingBurst(cf.Position, Color3.fromRGB(120,255,160), 0.6)
			end
		end
	end
end)
