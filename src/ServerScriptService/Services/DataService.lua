local Players = game:GetService("Players")
local ProfileStore -- optional
pcall(function() ProfileStore = require(script.Parent:FindFirstChild("ProfileStore")) end)

local profiles = {}
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
		-- TODO: wire actual ProfileStore binding here; keep fallback for Studio dev
	end
	profiles[player.UserId] = profiles[player.UserId] or table.clone(TEMPLATE)
	return profiles[player.UserId]
end

function M.SaveProfileAsync(player)
	-- TODO: if ProfileStore present, write back; else noop
	return true
end

function M.AddShards(player, amount)
	local p = profiles[player.UserId] or M.LoadProfileAsync(player)
	p.currencies.shards += amount
	return p.currencies.shards
end

function M.GrantBlueprintOrToken(userId)
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr.UserId == userId then
			M.AddShards(plr, 3)
			local p = profiles[userId]
			p.totalRescues += 1
			return true
		end
	end
	return false
end

return M
