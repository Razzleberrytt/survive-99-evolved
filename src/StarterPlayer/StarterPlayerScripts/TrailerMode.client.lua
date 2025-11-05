local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local player = Players.LocalPlayer

local enabled = false
local points = {
	CFrame.new(Vector3.new(-80, 40, -80), Vector3.new(0,10,0)),
	CFrame.new(Vector3.new(0, 35, -120), Vector3.new(0,8,0)),
	CFrame.new(Vector3.new(90, 30, -40), Vector3.new(0,10,0)),
	CFrame.new(Vector3.new(0, 25, 120), Vector3.new(0,10,0)),
}

local function runPath()
	local cam = workspace.CurrentCamera
	cam.CameraType = Enum.CameraType.Scriptable
	for i = 1, #points do
		local goal = { CFrame = points[i] }
		local t = TweenService:Create(cam, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), goal)
		t:Play(); t.Completed:Wait()
	end
	cam.CameraType = Enum.CameraType.Custom
end

-- Simple toggle via chat command: /trailer
game:GetService("Players").LocalPlayer.Chatted:Connect(function(msg)
	if msg:lower():match("^/trailer") then
		if enabled then return end
		enabled = true
		-- Start a night to get action
		Net.NightStartVote:FireServer()
		task.spawn(runPath)
		task.delay(12, function() enabled = false end)
	end
end)
