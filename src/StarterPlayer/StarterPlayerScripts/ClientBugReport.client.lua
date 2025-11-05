local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Players = game:GetService("Players")

-- Simple chat command: /bug <text>
Players.LocalPlayer.Chatted:Connect(function(msg)
	local text = msg:match("^/bug%s+(.+)$")
	if text then
		game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("BroadcastState"):FireServer() -- noop, placeholder
		print("[Bug] Submitted:", text)
	end
end)
