local Players = game:GetService("Players")
local ProfileStore = require(script.Parent.ProfileStore)

local profiles = {}
local SCHEMA = 1
local TEMPLATE = {
	_schema = SCHEMA,
	bestNight = 0,
	totalRescues = 0,
	currencies = { shards = 0 },
	talents = {},
	cosmetics = { outfits = {}, emotes = {}, campThemes = {} },
	beaconModsOwned = {},
	settings = { accessibility = { captions = true, reduceFlashes = true }, input = { stickLayout = "default" } },
}

local function migrate(p)
	p._schema = p._schema or 0
	if p._schema < 1 then
		-- future fields here
		p._schema = 1
	end
	return p
end

local M = {}

function M.LoadProfileAsync(player)
	local key = ("Player_%d"):format(player.UserId)
	local raw = ProfileStore.load(key, TEMPLATE)
	profiles[player.UserId] = migrate(raw)
	return profiles[player.UserId]
end

function M.SaveProfileAsync(player)
	local p = profiles[player.UserId]; if not p then return false end
	local key = ("Player_%d"):format(player.UserId)
	return ProfileStore.save(key, p)
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
			local p = profiles[userId]; p.totalRescues += 1
			return true
		end
	end
	return false
end

function M.GetProfileSnapshot(player)
	return profiles[player.UserId]
end

return M
