local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Captions = require(Rep.Shared.Captions)
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local gui = Instance.new("ScreenGui"); gui.Name = "HUD"; gui.ResetOnSpawn = false; gui.Parent = player:WaitForChild("PlayerGui")

local function makeLabel(name, posY)
	local t = Instance.new("TextLabel")
	t.Name = name; t.AnchorPoint = Vector2.new(0,0); t.Position = UDim2.new(0, 12, 0, posY)
	t.Size = UDim2.new(0, 320, 0, 28)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.BackgroundTransparency = 0.3
	t.TextScaled = false; t.Font = Enum.Font.GothamBold; t.TextSize = 18
	t.Parent = gui
	return t
end

local lblTop = makeLabel("Top", 12)
local lblMid = makeLabel("Mid", 44)
local caption = makeLabel("Caption", 76)

-- Caption helpers
local function setCaption(text)
	Captions.push(text, 2.5, function(msg) caption.Text = msg end)
end

local lblShards = Instance.new("TextLabel")
lblShards.Size = UDim2.new(0, 200, 0, 28)
lblShards.Position = UDim2.new(0, 12, 0, 108)
lblShards.BackgroundTransparency = 0.3
lblShards.TextXAlignment = Enum.TextXAlignment.Left
lblShards.Font = Enum.Font.GothamBold
lblShards.TextSize = 18
lblShards.Parent = gui

local function makeButton(name, x, text, callback)
	local b = Instance.new("TextButton"); b.Name = name; b.Text = text
	b.Size = UDim2.new(0, 120, 0, 40); b.Position = UDim2.new(0, x, 1, -52); b.AnchorPoint = Vector2.new(0,1)
	b.Parent = gui
	b.MouseButton1Click:Connect(function() pcall(callback) end)
	return b
end

makeButton("StartNight", 12, "Start Night", function()
	Net.NightStartVote:FireServer()
end)

makeButton("FuelPlus", 140, "+5 Fuel", function()
	local ok, res = Net.FuelBeacon:InvokeServer({ amount = 5 })
end)

local function label(x, y, w, h, name)
	local t = Instance.new("TextLabel")
	t.Size = UDim2.new(0, w, 0, h)
	t.Position = UDim2.new(0, x, 0, y)
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.BackgroundTransparency = 0.3
	t.Font = Enum.Font.Gotham
	t.TextSize = 16
	t.Parent = gui
	return t
end

local lblCount = label(340, 12, 220, 28, "Count")

makeButton("PlaceWall", 272, "Place Wall", function()
	local cf = CFrame.new(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 12)
	local ok = Net.PlaceRequest:InvokeServer({ placeType = "Wall", position = cf.Position })
end)

makeButton("PlaceSpike", 400, "Place Spike", function()
	local cf = CFrame.new(workspace.CurrentCamera.CFrame.Position + workspace.CurrentCamera.CFrame.LookVector * 12)
	local ok = Net.PlaceRequest:InvokeServer({ placeType = "TrapSpike", position = cf.Position })
end)

local btnEscort = makeButton("Escort", 528, "Escort", function()
	Net.RescueInteract:InvokeServer({ id = "current", action = "Escort" })
end)

local btnAcc = makeButton("Accessibility", 656, "Reduce Flashes", function()
	local ok = Net.ToggleSetting:InvokeServer({ category = "accessibility", key = "reduceFlashes", value = true })
	setCaption("Reduce flashes: ON")
end)

local btnShop = makeButton("Shop", 780, "Shop", function()
	local ok, res = Net.PurchaseProduct:InvokeServer({ productKey = "shards_100" })
	if not ok then setCaption("Shop unavailable: "..tostring(res)) else setCaption("Purchase prompt opened") end
end)

local shardCount = 0
local function setShards(n) shardCount = n; lblShards.Text = "Shards: "..tostring(shardCount) end
setShards(0)
task.spawn(function()
	while true do
		task.wait(5)
		local prof = Net.GetProfile:InvokeServer()
		if prof and prof.currencies then setShards(prof.currencies.shards or 0) end
	end
end)

-- Count updates when BroadcastState arrives (just refresh)
local function refreshCount()
	local n = 0
	for _, p in ipairs(workspace:GetChildren()) do
		if p:IsA("BasePart") and p.Name:match("^Enemy_") then n += 1 end
	end
	lblCount.Text = "Enemies: "..tostring(n)
end

game:GetService("RunService").RenderStepped:Connect(refreshCount)

local night, phase, omen = 0, "Lobby", ""
local function draw()
	lblTop.Text = string.format("Night %d  |  Phase %s", night, phase)
	lblMid.Text = omen ~= "" and ("Omen: "..omen) or ""
end

Net.BroadcastState.OnClientEvent:Connect(function(state)
	night = state.night or night
	phase = state.phase or phase
	omen = state.omen or ""
	if state.shards ~= nil then setShards(state.shards) end
	draw()
end)

Net.BeaconChanged.OnClientEvent:Connect(function(s)
	setCaption(string.format("Beacon Fuel:%d Heat:%d Radius:%d", s.fuel, s.heat, s.lightRadius))
end)

draw()

Net.BroadcastState.OnClientEvent:Connect(function(state)
	if state.omen then setCaption("Omen: "..tostring(state.omen)) end
end)

Net.BroadcastState.OnClientEvent:Connect(function(state)
	if state.rescue == "spawned" then
		setCaption("Rescue available — find the blue flare!")
	elseif state.rescue == "complete" then
		setCaption("Rescue complete! Reward granted.")
	end
end)
