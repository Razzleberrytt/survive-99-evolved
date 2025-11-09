local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui")
gui.Name = "Tutorial"
gui.ResetOnSpawn = false
gui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Size = UDim2.new(1, 0, 0, 120)
frame.Position = UDim2.new(0,0,0,0)
frame.BackgroundTransparency = 0.25
frame.Parent = gui

local label = Instance.new("TextLabel")
label.Size = UDim2.new(1, 0, 1, 0)
label.TextScaled = true
label.BackgroundTransparency = 1
label.Font = Enum.Font.GothamBold
label.Text = ""
label.Parent = frame

local function show(msg)
	label.Text = msg
	frame.Visible = true
end

local function hide()
	frame.Visible = false
end

Net.TutorialEvent.OnClientEvent:Connect(function(payload)
        if not payload then return end
        if payload.step == nil then return end
        if payload.step == "fuel" then
                show("Step 1: Tap +5 Fuel to feed the Beacon.")
        elseif payload.step == "place" then
		show("Step 2: Place a Wall near the beacon.")
	elseif payload.step == "start" then
		show("Step 3: Press Start Night.")
	elseif payload.step == "done" then
		show("Tutorial complete! Good luck.")
		task.delay(2.5, hide)
	end
end)
