local PolicyService = game:GetService("PolicyService")

local Adapter = {}

function Adapter:GetPolicy(player)
    local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
    if not ok or not info then
        return { under13 = false, canTrade = false, canGacha = false }
    end
    return {
        under13 = info.ArePaidRandomItemsRestricted or false,
        canTrade = info.ArePaidItemTradingAllowed or false,
        canGacha = not info.ArePaidRandomItemsRestricted,
    }
end

return Adapter
