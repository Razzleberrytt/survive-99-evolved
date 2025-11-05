local MemoryStoreService = game:GetService("MemoryStoreService")
local Rep = game:GetService("ReplicatedStorage")
local LiveConfig = require(script.Parent.LiveConfigService)

local M = {}
-- FILL THIS with your Roblox user IDs (devs who can use Admin Panel)
M.Admins = {
	-- 12345678, -- you
}

local function isAdmin(userId: number)
	for _, id in ipairs(M.Admins) do
		if id == userId then return true end
	end
	return false
end

local function saveToMemoryStore()
	local map = MemoryStoreService:GetMap("Survive99_LiveConfig_v1")
	local payload = {
		FeatureFlags = LiveConfig.FeatureFlags,
		Tuning = LiveConfig.Tuning,
	}
	local ok, err = pcall(function()
		map:SetAsync("live", payload, 60*60) -- 1h TTL; refreshed by LiveConfigService
	end)
	if not ok then warn("[LiveConfigAdmin] Save failed:", err) end
	return ok
end

function M.SetFlag(userId, key, value)
	if not isAdmin(userId) then return false, "not_admin" end
	LiveConfig.FeatureFlags[key] = value
	saveToMemoryStore()
	return true
end

-- path can be "omens.Fog" or "waveCap"
local function setPath(tbl, path, value)
	local cur = tbl
	local parts = string.split(path, ".")
	for i = 1, #parts-1 do
		cur[parts[i]] = cur[parts[i]] or {}
		cur = cur[parts[i]]
	end
	cur[parts[#parts]] = value
end

function M.SetTuning(userId, path, value)
	if not isAdmin(userId) then return false, "not_admin" end
	setPath(LiveConfig.Tuning, path, value)
	saveToMemoryStore()
	return true
end

function M.IsAdmin(userId) return isAdmin(userId) end

return M
