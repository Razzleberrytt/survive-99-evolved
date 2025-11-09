local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Store = require(ReplicatedStorage:WaitForChild("Config"):WaitForChild("Store"))

local function log(eventName, fields)
  print(("[telemetry] %s :: %s"):format(eventName, HttpService:JSONEncode(fields)))
end

local ReceiptsDS = DataStoreService:GetDataStore("PurchaseReceipts_v1")

local function grantProduct(player, productId)
  local def = Store.Products[productId]
  if not def then return false, "unknown_product" end
  -- TODO: integrate your real currency/inventory award here.
  log("purchase_grant", { userId = player.UserId, productId = productId, amount = def.amount })
  return true, "granted"
end

local function processReceipt(receiptInfo)
  local key = string.format("%d:%s", receiptInfo.PlayerId, receiptInfo.PurchaseId)
  local alreadyProcessed
  local ok, err = pcall(function() alreadyProcessed = ReceiptsDS:GetAsync(key) end)
  if not ok then
    log("receipt_datastore_error", { err = tostring(err) })
    return Enum.ProductPurchaseDecision.NotProcessedYet
  end
  if alreadyProcessed then return Enum.ProductPurchaseDecision.PurchaseGranted end

  local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
  if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end

  local granted, reason = grantProduct(player, receiptInfo.ProductId)
  if not granted then
    log("purchase_failed", { userId = receiptInfo.PlayerId, productId = receiptInfo.ProductId, reason = reason })
    return Enum.ProductPurchaseDecision.NotProcessedYet
  end

  pcall(function() ReceiptsDS:SetAsync(key, true) end)
  log("purchase_success", { userId = receiptInfo.PlayerId, productId = receiptInfo.ProductId })
  return Enum.ProductPurchaseDecision.PurchaseGranted
end

MarketplaceService.ProcessReceipt = processReceipt
log("receipt_handler_ready", {})
