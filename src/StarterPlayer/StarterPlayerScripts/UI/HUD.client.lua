local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Net = require(ReplicatedStorage.Remotes.Net)

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

local function createLabel(name: string, position: UDim2)
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(0, 220, 0, 28)
	label.Position = position
	label.BackgroundTransparency = 0.3
	label.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
	label.TextColor3 = Color3.new(1, 1, 1)
	label.Font = Enum.Font.GothamMedium
	label.TextSize = 18
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Text = "--"
	label.Parent = screenGui
	return label
end

local nightLabel = createLabel("NightLabel", UDim2.fromOffset(20, 20))
local fuelLabel = createLabel("FuelLabel", UDim2.fromOffset(20, 52))
local squadsLabel = createLabel("SquadsLabel", UDim2.fromOffset(20, 84))

local function update(state)
	if not state then
		return
	end
	nightLabel.Text = string.format("Night %d | Phase %s", state.night or 0, state.phase or "--")
	local beacon = state.beacon or {}
	fuelLabel.Text = string.format("Fuel %.0f | Heat %.0f", beacon.fuel or 0, beacon.heat or 0)
	squadsLabel.Text = string.format("Active Squads %s", tostring(state.activeSquads or "--"))
end

Net.BroadcastState.OnClientEvent:Connect(update)
