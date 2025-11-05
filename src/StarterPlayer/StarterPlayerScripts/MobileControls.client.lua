local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local UserInputService = game:GetService("UserInputService")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

local player = Players.LocalPlayer

-- Sprint: hold virtual button to set WalkSpeed to 20 (clamped)
local gui = Instance.new("ScreenGui")
gui.Name = "MobileControls"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")

local sprint = Instance.new("TextButton")
sprint.Text = "Sprint"; sprint.Size = UDim2.new(0, 120, 0, 60)
sprint.Position = UDim2.new(1, -132, 1, -68); sprint.AnchorPoint = Vector2.new(0,1)
sprint.BackgroundTransparency = 0.2; sprint.Parent = gui

local function applySpeed(on)
	local char = player.Character
	if not char then return end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum then return end
	hum.WalkSpeed = on and 20 or 16
end

sprint.MouseButton1Down:Connect(function() applySpeed(true) end)
sprint.MouseButton1Up:Connect(function() applySpeed(false) end)
player.CharacterAdded:Connect(function()
	task.wait(0.1); applySpeed(false)
end)

-- Enlarge existing HUD buttons if on mobile
if UserInputService.TouchEnabled then
	for _, guiObj in ipairs(player.PlayerGui:GetDescendants()) do
		if guiObj:IsA("TextButton") then
			guiObj.Size = guiObj.Size + UDim2.new(0, 20, 0, 12)
		end
	end
end
