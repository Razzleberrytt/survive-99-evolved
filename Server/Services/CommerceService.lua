local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local DataService = require(script.Parent.DataService)
local Products = require(game.ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Config"):WaitForChild("Products"))

local CommerceService = {}

local function grant(player, product)
    return DataService:WithProfile(player, function(data)
        if product.kind == "coins" then data.coins += product.amount end
        if product.kind == "revive" then
            data.inventory.revives = (data.inventory.revives or 0) + product.amount
        end
    end)
end

function CommerceService:Init()
    MarketplaceService.ProcessReceipt = function(info)
        local product = Products[info.ProductId]
        if not product then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local player = Players:GetPlayerByUserId(info.PlayerId)
        if not player then return Enum.ProductPurchaseDecision.NotProcessedYet end
        local ok = false
        DataService:WithProfile(player, function(data)
            if data.receipts[info.PurchaseId] then ok = true return end
            local granted = select(1, grant(player, product))
            if granted then
                data.receipts[info.PurchaseId] = true
                ok = true
            end
        end)
        return ok and Enum.ProductPurchaseDecision.PurchaseGranted or Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

return CommerceService
