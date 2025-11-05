local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(Rep.Remotes.Net)
local DataService = require(script.Parent.DataService)

local M = {}
local progress = {} -- [userId] = { step="fuel"|"place"|"start"|"done" }

local function pushStep(plr, step)
	Net.TutorialEvent:FireClient(plr, { step = step })
end

function M.Begin(player)
	local prof = DataService.LoadProfileAsync(player)
	if prof.tutorialComplete then return end
	progress[player.UserId] = progress[player.UserId] or { step = "fuel" }
	pushStep(player, "fuel")
end

function M.OnAction(player, action)
	local st = progress[player.UserId]; if not st then return end
	if st.step == "fuel" and action == "fuel" then
		st.step = "place"; pushStep(player, "place")
	elseif st.step == "place" and action == "place" then
		st.step = "start"; pushStep(player, "start")
	elseif st.step == "start" and action == "start" then
		st.step = "done"
		local prof = DataService.GetProfileSnapshot(player)
		prof.tutorialComplete = true
		Net.TutorialEvent:FireClient(player, { step = "done" })
	end
end

return M
