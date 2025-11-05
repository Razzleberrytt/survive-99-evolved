local Rep = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local Data = require(script.Parent.DataService)
local Catalog = require(Rep.Shared.Config.Cosmetics)

local M = {}

local function rotationIds(dayIndex: number)
	-- deterministic daily pick
	local ids = {}
	for id, _ in pairs(Catalog.Items) do table.insert(ids, id) end
	table.sort(ids)
	local out = {}
	local n = Catalog.DailyCount or 4
	for i = 1, #ids do
		if ((i + dayIndex) % 5) < n then table.insert(out, ids[i]) end
	end
	return out
end

function M.GetShop(player)
	local day = os.date("*t").yday
	local picks = rotationIds(day)
	local snapshot = Data.GetProfileSnapshot(player) or Data.LoadProfileAsync(player)
	local owned = (snapshot and snapshot.cosmetics) or { outfits={}, campThemes={} }
	owned.outfits = owned.outfits or {}
	owned.campThemes = owned.campThemes or {}
	return {
		day = day,
		items = picks,
		catalog = Catalog.Items,
		owned = owned,
		equipped = {
			camp = snapshot and snapshot.equippedCamp or nil,
			outfit = snapshot and snapshot.equippedOutfit or nil,
		}
	}
end

function M.Owns(player, id)
	local prof = Data.GetProfileSnapshot(player) or Data.LoadProfileAsync(player)
	local it = Catalog.Items[id]; if not it then return false end
	local bucket = it.type == "camp" and "campThemes" or "outfits"
	prof.cosmetics = prof.cosmetics or { outfits = {}, campThemes = {} }
	prof.cosmetics.outfits = prof.cosmetics.outfits or {}
	prof.cosmetics.campThemes = prof.cosmetics.campThemes or {}
	for _, v in ipairs(prof.cosmetics[bucket]) do if v == id then return true end end
	return false
end

function M.Buy(player, id)
	local it = Catalog.Items[id]; if not it then return false, "unknown" end
	if M.Owns(player, id) then return true, "owned" end
	local prof = Data.GetProfileSnapshot(player) or Data.LoadProfileAsync(player)
	local cost = it.cost or 10
	if (prof.currencies.shards or 0) < cost then return false, "not_enough_shards" end
	prof.currencies.shards -= cost
	local bucket = it.type == "camp" and "campThemes" or "outfits"
	prof.cosmetics = prof.cosmetics or { outfits = {}, campThemes = {} }
	prof.cosmetics.outfits = prof.cosmetics.outfits or {}
	prof.cosmetics.campThemes = prof.cosmetics.campThemes or {}
	table.insert(prof.cosmetics[bucket], id)
	return true, "ok"
end

function M.Equip(player, id)
	if not M.Owns(player, id) then return false, "not_owned" end
	local it = Catalog.Items[id]
	local prof = Data.GetProfileSnapshot(player) or Data.LoadProfileAsync(player)
	if it.type == "camp" then prof.equippedCamp = id else prof.equippedOutfit = id end
	return true, "ok"
end

return M
