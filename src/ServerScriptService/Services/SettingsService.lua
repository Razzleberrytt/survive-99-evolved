local Rep = game:GetService("ReplicatedStorage")
local DataService = require(script.Parent.DataService)
local M = {}

function M.Toggle(player, category, key, value)
	local prof = DataService.GetProfileSnapshot(player) or DataService.LoadProfileAsync(player)
	prof.settings = prof.settings or {}
	prof.settings[category] = prof.settings[category] or {}
	prof.settings[category][key] = value
	return true, prof.settings[category][key]
end

return M
