local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local phaseStateChanged = remotes:WaitForChild(RemoteNames.PhaseStateChanged)
local beaconStateChanged = remotes:WaitForChild(RemoteNames.BeaconStateChanged)

local gui = Instance.new("ScreenGui")
gui.Name = "PhaseBeaconHUD"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = false
gui.Parent = player:WaitForChild("PlayerGui")

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(1, 0)
panel.Position = UDim2.new(1, -12, 0, 12)
panel.Size = UDim2.new(0, 300, 0, 112)
panel.BackgroundColor3 = Color3.fromRGB(12, 18, 28)
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
layout.Padding = UDim.new(0, 4)
layout.Parent = panel

local function makeLabel(name: string): TextLabel
	local label = Instance.new("TextLabel")
	label.Name = name
	label.Size = UDim2.new(1, 0, 0, 28)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextColor3 = Color3.fromRGB(245, 248, 255)
	label.TextSize = 20
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.TextYAlignment = Enum.TextYAlignment.Center
	label.Parent = panel
	return label
end

local phaseLabel = makeLabel("Phase")
local timeLabel = makeLabel("TimeRemaining")
local beaconLabel = makeLabel("Beacon")

local latestPhase = nil
local latestBeacon = nil

local function secondsRemaining(phaseState): number
	local endsAt = phaseState and phaseState.endsAt or 0
	return math.max(0, math.ceil(endsAt - workspace:GetServerTimeNow()))
end

local function render()
	if latestPhase then
		phaseLabel.Text = string.format("Night %d • %s", latestPhase.night or 0, latestPhase.phase or "Lobby")
		timeLabel.Text = string.format("Time remaining: %ds", secondsRemaining(latestPhase))
	else
		phaseLabel.Text = "Night 0 • Waiting"
		timeLabel.Text = "Time remaining: --"
	end

	if latestBeacon then
		beaconLabel.Text = string.format(
			"Beacon: %d/%d HP • %d/%d Shield",
			math.floor(latestBeacon.hp or 0),
			math.floor(latestBeacon.maxHp or 0),
			math.floor(latestBeacon.shield or 0),
			math.floor(latestBeacon.maxShield or 0)
		)
	else
		beaconLabel.Text = "Beacon: waiting for state"
	end
end

phaseStateChanged.OnClientEvent:Connect(function(phaseState)
	latestPhase = phaseState
	print(string.format(
		"[PhaseBeaconHUD] Phase update: night=%s phase=%s",
		tostring(phaseState.night),
		tostring(phaseState.phase)
	))
	render()
end)

beaconStateChanged.OnClientEvent:Connect(function(beaconState)
	latestBeacon = beaconState
	print(string.format(
		"[PhaseBeaconHUD] Beacon update: hp=%s shield=%s fuel=%s",
		tostring(beaconState.hp),
		tostring(beaconState.shield),
		tostring(beaconState.fuel)
	))
	render()
end)

render()
