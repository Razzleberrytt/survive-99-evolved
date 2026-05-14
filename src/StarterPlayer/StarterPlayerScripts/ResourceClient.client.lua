local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local resourceStateChanged = remotes:WaitForChild(RemoteNames.ResourceStateChanged)
local requestDepositResource = remotes:WaitForChild(RemoteNames.RequestDepositResource)

local RESOURCE_ORDER = { "Wood", "Scrap", "Food", "Fuel", "Essence" }

local gui = Instance.new("ScreenGui")
gui.Name = "ResourceHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 132)
panel.Size = UDim2.new(0, 300, 0, 126)
panel.BackgroundColor3 = Color3.fromRGB(16, 24, 20)
panel.BackgroundTransparency = 0.18
panel.BorderSizePixel = 0
panel.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = panel

local padding = Instance.new("UIPadding")
padding.PaddingTop = UDim.new(0, 10)
padding.PaddingBottom = UDim.new(0, 10)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Left
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 5)
layout.Parent = panel

local function makeLabel(name: string, textSize: number): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, 24)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(238, 255, 242)
	label.TextSize = textSize
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = panel
	return label
end

local titleLabel = makeLabel("Title", 19)
local personalLabel = makeLabel("PersonalResources", 16)
local teamLabel = makeLabel("TeamResources", 16)

local depositButton = Instance.new("TextButton")
depositButton.Name = "DepositAll"
depositButton.Size = UDim2.new(1, 0, 0, 36)
depositButton.BackgroundColor3 = Color3.fromRGB(56, 130, 82)
depositButton.TextColor3 = Color3.fromRGB(255, 255, 255)
depositButton.Font = Enum.Font.GothamBold
depositButton.TextSize = 18
depositButton.Text = "Deposit All"
depositButton.Parent = panel

local buttonCorner = Instance.new("UICorner")
buttonCorner.CornerRadius = UDim.new(0, 8)
buttonCorner.Parent = depositButton

local latestState = nil

local function summarize(inventory): string
	if typeof(inventory) ~= "table" then
		return "waiting"
	end

	local parts = {}
	for _, resourceType in ipairs(RESOURCE_ORDER) do
		table.insert(parts, string.format("%s %d", resourceType, math.floor(inventory[resourceType] or 0)))
	end
	return table.concat(parts, " • ")
end

local function render()
	titleLabel.Text = "Resources"
	if latestState then
		personalLabel.Text = "Carry: " .. summarize(latestState.personal)
		teamLabel.Text = "Team: " .. summarize(latestState.team)
	else
		personalLabel.Text = "Carry: waiting for state"
		teamLabel.Text = "Team: waiting for state"
	end
end

resourceStateChanged.OnClientEvent:Connect(function(resourceState)
	latestState = resourceState
	print("[ResourceHUD] Resource update", summarize(resourceState and resourceState.personal), summarize(resourceState and resourceState.team))
	render()
end)

depositButton.MouseButton1Click:Connect(function()
	requestDepositResource:FireServer({})
end)

render()
