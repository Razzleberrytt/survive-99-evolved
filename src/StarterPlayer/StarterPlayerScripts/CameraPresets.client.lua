local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local presets = {
	iconA = CFrame.new(Vector3.new(-26, 18, -24), Vector3.new(0,5,0)),
	iconB = CFrame.new(Vector3.new(24, 16, -26), Vector3.new(0,5,0)),
	iconC = CFrame.new(Vector3.new(0, 22, -36), Vector3.new(0,5,0)),
}

local function setCam(cf, t)
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	TweenService:Create(cam, TweenInfo.new(t or 1.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {CFrame=cf}):Play()
end

Players.LocalPlayer.Chatted:Connect(function(msg)
	msg = msg:lower()
	if msg == "/icona" then setCam(presets.iconA) end
	if msg == "/iconb" then setCam(presets.iconB) end
	if msg == "/iconc" then setCam(presets.iconC) end
end)
