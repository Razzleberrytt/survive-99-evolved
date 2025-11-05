local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Notes = require(Rep.Shared.Config.PatchNotes)
local Data = require(script.Parent.DataService)

local M = {}
function M.PushIfNew(player)
	local prof = Data.GetProfileSnapshot(player) or Data.LoadProfileAsync(player)
	if prof.lastSeenVersion ~= Notes.version then
		Net.PatchNotesEvt:FireClient(player, Notes)
		prof.lastSeenVersion = Notes.version
	end
end
return M
