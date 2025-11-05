-- Kicks (politely) if SoftLaunch gate blocks player.
local Services = script.Parent.Parent:WaitForChild("Services")
local SoftLaunch = require(Services.SoftLaunchService)
local Analytics = require(Services.AnalyticsAdapter)
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

game.Players.PlayerAdded:Connect(function(plr)
	local allow, reason = SoftLaunch.ShouldAllow(plr)
	if not allow then
		Analytics.SoftGateBlocked(plr, reason or "unknown")
		Net.TutorialEvent:FireClient(plr, { step = "done" })
		task.wait(0.25)
		plr:Kick("Soft Launch: access limited right now. Please try again soon!")
	end
end)
