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
        equippedCamp = nil,
        equippedOutfit = nil,
        lastSeenVersion = nil,
        codex = { seen = {}, completed = {} },
}

local function migrate(p)
	p._schema = p._schema or 0
	if p._schema < 1 then
		-- future fields here
		p._schema = 1
	end
	p.equippedCamp = p.equippedCamp or nil
	p.equippedOutfit = p.equippedOutfit or nil
	p.lastSeenVersion = p.lastSeenVersion or nil
	p.cosmetics = p.cosmetics or { outfits = {}, emotes = {}, campThemes = {} }
        p.cosmetics.outfits = p.cosmetics.outfits or {}
        p.cosmetics.campThemes = p.cosmetics.campThemes or {}
        p.cosmetics.emotes = p.cosmetics.emotes or {}
        p.currencies = p.currencies or { shards = 0 }
        p.codex = p.codex or { seen = {}, completed = {} }
        p.codex.seen = p.codex.seen or {}
        p.codex.completed = p.codex.completed or {}
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

local function ensureCodex(player)
        local profile = profiles[player.UserId] or M.LoadProfileAsync(player)
        profile.codex = profile.codex or { seen = {}, completed = {} }
        profile.codex.seen = profile.codex.seen or {}
        profile.codex.completed = profile.codex.completed or {}
        return profile
end

function M.MarkCodexSeen(player, promptId)
        if not promptId then return end
        local profile = ensureCodex(player)
        profile.codex.seen[promptId] = true
end

function M.MarkCodexCompleted(player, promptId)
        if not promptId then return end
        local profile = ensureCodex(player)
        profile.codex.completed[promptId] = true
end

return M
