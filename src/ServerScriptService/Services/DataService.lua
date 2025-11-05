local Players = game:GetService("Players")

-- Try to require a ProfileStore module placed at ServerScriptService/Services/ProfileStore.lua (optional).
local ProfileStore
pcall(function() ProfileStore = require(script.Parent:FindFirstChild("ProfileStore")) end)

local profiles = {} -- in-memory fallback

local TEMPLATE = {
	_schema = 1,
	bestNight = 0,
	totalRescues = 0,
	currencies = { shards = 0 },
	talents = {},
	cosmetics = { outfits = {}, emotes = {}, campThemes = {} },
	beaconModsOwned = {},
	settings = { accessibility = { captions = true, reduceFlashes = true }, input = { stickLayout = "default" } },
}

local M = {}

function M.LoadProfileAsync(player)
	if ProfileStore then
		-- TODO: wire actual ProfileStore here (session locking)
		-- For now, still fall back to memory to avoid Studio DataStore prompts.
	end
	profiles[player.UserId] = profiles[player.UserId] or table.clone(TEMPLATE)
	return profiles[player.UserId]
end

function M.SaveProfileAsync(player)
	return true
end

function M.Award(player, item)
	local prof = profiles[player.UserId]; if not prof then return false end
	table.insert(prof.beaconModsOwned, item)
	return true
end

return M
