local Rep = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Net = require(Rep.Remotes.Net)
local Players = game:GetService("Players")

local gui = Instance.new("ScreenGui")
gui.Name = "PerformanceOverlay"; gui.ResetOnSpawn = false; gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

local label = Instance.new("TextLabel")
label.Size = UDim2.new(0, 220, 0, 28)
label.Position = UDim2.new(1, -232, 0, 8)
label.AnchorPoint = Vector2.new(0,0)
label.BackgroundTransparency = 0.3
label.TextXAlignment = Enum.TextXAlignment.Left
label.Font = Enum.Font.Gotham
label.TextSize = 16
label.Text = "FPS --  |  RTT -- ms"
label.Parent = gui

local fps, alpha = 60, 0.1
RunService.RenderStepped:Connect(function(dt)
	local inst = 1/math.max(dt, 1/240)
	fps = fps*(1-alpha) + inst*alpha
end)

task.spawn(function()
	while true do
		local t0 = os.clock()
		local ok, tServer = pcall(function()
			return Net.PerfPing:InvokeServer({ tClient = t0 })
		end)
		local rtt = ok and math.floor((os.clock() - t0)*1000) or -1
		label.Text = string.format("FPS %d  |  RTT %d ms", math.floor(fps+0.5), rtt)
		task.wait(1)
	end
end)
