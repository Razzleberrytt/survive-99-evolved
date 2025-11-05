local Rep = game:GetService("ReplicatedStorage")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")
local LiveConfig = require(script.Parent.LiveConfigService)

local M = {}

local function isWhitelisted(userId)
	for _, id in ipairs(LiveConfig.FeatureFlags.whitelistUserIds) do
		if id == userId then return true end
	end
	return false
end

local function accountAgeOK(player)
	local minDays = LiveConfig.FeatureFlags.minAccountAgeDays or 0
	return (player.AccountAge or 0) >= minDays
end

local function regionOK(player)
	local ok, pol = pcall(function() return PolicyService:GetPolicyInfoForPlayerAsync(player) end)
	if not ok or not pol then return true end -- fail open if policy unavailable
	local country = pol.CountryCode or "??"
	local allowed = LiveConfig.FeatureFlags.softLaunchRegions
	if not allowed or #allowed == 0 then return true end
	for _, code in ipairs(allowed) do
		if code == country then return true end
	end
	return false
end

function M.ShouldAllow(player)
	if not LiveConfig.FeatureFlags.softLaunch then return true end
	if isWhitelisted(player.UserId) then return true end
	if not accountAgeOK(player) then return false, "account_age" end
	if not regionOK(player) then return false, "region" end
	return true
end

return M
