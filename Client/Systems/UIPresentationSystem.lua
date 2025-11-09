local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)

local UI = {}

function UI.Start()
    local policyEv = Remotes.get("UX_Policy")
    if policyEv then
        policyEv.OnClientEvent:Connect(function(policy)
            -- TODO: disable restricted UI bits (e.g., shop buttons) based on policy
            print("[Policy]", policy and policy.under13 and "U13" or "13+")
        end)
    end
end

return UI
