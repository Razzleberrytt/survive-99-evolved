local Rep = game:GetService("ReplicatedStorage")
local MarketplaceService = game:GetService("MarketplaceService")
local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")

local LiveConfig = require(script.Parent.LiveConfigService)
local StoreIDs = require(Rep.Shared.Config.Store)

local M = {}

local function checkPolicy(player)
	local ok, pol = pcall(function() return PolicyService:GetPolicyInfoForPlayerAsync(player) end)
	if not ok or not pol then
		return { allowIAP = false, allowSubscriptions = false, allowAds = false }
	end
	local under13 = pol.Under13 or false
	local allowIAP = LiveConfig.FeatureFlags.enableIAP and (not under13)
	local allowSubs = LiveConfig.FeatureFlags.enableSubscriptions and (not under13)
	local allowAds = LiveConfig.FeatureFlags.enableAds and (not under13)
	return { allowIAP = allowIAP, allowSubscriptions = allowSubs, allowAds = allowAds }
end

function M.CanOffer(player)
	return checkPolicy(player)
end

function M.PurchaseDevProduct(player, key)
	local id = StoreIDs.DevProducts[key]; if not id then return false, "unknown_product" end
	local ok, err = pcall(function() MarketplaceService:PromptProductPurchase(player, id) end)
	return ok, err
end

function M.PromptGamePass(player, key)
	local id = StoreIDs.GamePasses[key]; if not id then return false, "unknown_pass" end
	local ok, err = pcall(function() MarketplaceService:PromptGamePassPurchase(player, id) end)
	return ok, err
end

return M
