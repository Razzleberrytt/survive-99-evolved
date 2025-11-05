local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local VFX = require(Rep.Shared.VFX)
local Config = require(Rep.Shared.Config.Credits)

local gui = Instance.new("ScreenGui")
gui.Name = "Credits"; gui.ResetOnSpawn = false; gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.AnchorPoint = Vector2.new(0.5,0.5)
frame.Position = UDim2.fromScale(0.5,0.5)
frame.Size = UDim2.fromOffset(560, 320)
frame.BackgroundTransparency = 0.2
frame.Visible = false
frame.Parent = gui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBlack
title.Text = Config.dedication
title.TextWrapped = true
title.Parent = frame

local list = Instance.new("TextLabel")
list.Position = UDim2.new(0,0,0,56)
list.Size = UDim2.new(1,0,1,-56)
list.BackgroundTransparency = 1
list.Font = Enum.Font.Gotham
list.TextWrapped = true
list.TextYAlignment = Enum.TextYAlignment.Top
list.Text = table.concat(Config.credits, "\n")
list.Parent = frame

-- Chat commands
Players.LocalPlayer.Chatted:Connect(function(msg)
	if msg:lower():match("^/credits") then
		frame.Visible = not frame.Visible
	elseif msg:lower():match("^/confetti") or msg:lower():match("^/egg") then
		local char = Players.LocalPlayer.Character
		if char and char.PrimaryPart then
			VFX.spawnRingBurst(char.PrimaryPart.Position, Color3.fromRGB(180, 220, 255), 1.2)
		end
	end
end)
