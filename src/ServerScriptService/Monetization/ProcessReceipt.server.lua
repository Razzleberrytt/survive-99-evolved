-- Basic receipt handler scaffold. Wire into your currency/data modules.
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Store = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Store"))

-- Lightweight telemetry queue (replace with your real telemetry if you have one)
local function log(eventName, fields)
	print(("[telemetry] %s :: %s"):format(eventName, game:GetService("HttpService"):JSONEncode(fields)))
end

local ReceiptsDS = DataStoreService:GetDataStore("PurchaseReceipts_v1")

local function grantProduct(player, productId)
	local def = Store.Products[productId]
	if not def then
		return false, "unknown_product"
	end

	-- TODO: integrate your real currency/inventory award here.
	-- Example: Currency:add(player.UserId, def.amount)
	log("purchase_grant", { userId = player.UserId, productId = productId, amount = def.amount })
	return true, "granted"
end

local function processReceipt(receiptInfo)
	-- Idempotency check
	local key = string.format("%d:%s", receiptInfo.PlayerId, receiptInfo.PurchaseId)
	local alreadyProcessed = nil
	local success, err = pcall(function()
		alreadyProcessed = ReceiptsDS:GetAsync(key)
	end)
	if not success then
		log("receipt_datastore_error", { err = tostring(err) })
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end
	if alreadyProcessed then
		return Enum.ProductPurchaseDecision.PurchaseGranted
	end

	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player left; retry later
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local ok, reason = grantProduct(player, receiptInfo.ProductId)
	if not ok then
		log("purchase_failed", { userId = player.UserId, productId = receiptInfo.ProductId, reason = reason })
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Mark processed
	pcall(function()
		ReceiptsDS:SetAsync(key, true)
	end)

	log("purchase_success", { userId = player.UserId, productId = receiptInfo.ProductId })
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
log("receipt_handler_ready", {})
