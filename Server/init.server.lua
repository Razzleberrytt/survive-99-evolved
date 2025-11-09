local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure Shared folder exists for config/modules (Rojo should map this)
local Shared = ReplicatedStorage:FindFirstChild("Shared") or Instance.new("Folder")
Shared.Name = "Shared"
Shared.Parent = ReplicatedStorage

local Remotes = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Net"):WaitForChild("Remotes"))
local DataService = require(script.Parent.Services.DataService)
local CommerceService = require(script.Parent.Services.CommerceService)
local PolicyAdapter = require(script.Parent.Services.PolicyServiceAdapter)
local RateLimiter = require(script.Parent.Net.RateLimiter)
local validate = require(script.Parent.Net.Validator)

local NetTypes = require(ReplicatedStorage.Shared.Types.NetTypes)
local Products = require(ReplicatedStorage.Shared.Config.Products)

-- Create remotes
local R_IN = {
    "Input_Fire",
    "Input_Attack",
    "Input_Revive",
    "Menu_RequestPurchase",
}
local R_OUT = {
    "State_DamageApplied",
    "State_WaveUpdate",
    "Economy_Balance",
    "UX_Policy",
}
for _, n in ipairs(R_IN) do Remotes.create(n) end
for _, n in ipairs(R_OUT) do Remotes.create(n) end

-- Rate limit buckets per player per remote
local buckets = {}

local function bucketFor(plr, name)
    buckets[plr] = buckets[plr] or {}
    local b = buckets[plr][name]
    if not b then
        local rate, burst = 10, 10
        if name == "Input_Attack" then rate, burst = 3, 3 end
        if name == "Input_Revive" then rate, burst = 2, 2 end
        if name == "Menu_RequestPurchase" then rate, burst = 1, 1 end
        b = RateLimiter.new(rate, burst)
        buckets[plr][name] = b
    end
    return b
end

-- Bind incoming handlers
for name, spec in pairs(NetTypes.ClientToServer) do
    local ev = Remotes.get(name)
    if ev then
        ev.OnServerEvent:Connect(function(player, payload)
            local b = bucketFor(player, name)
            if not b:allow() then return end
            local ok, err = validate(spec, payload or {})
            if not ok then return end

            if name == "Menu_RequestPurchase" then
                local p = Products[payload.productId]
                if not p then return end
                MarketplaceService:PromptProductPurchase(player, payload.productId)
                return
            end

            -- TODO: route to gameplay systems (Combat, Revive, etc.)
        end)
    end
end

-- Player policy on join
Players.PlayerAdded:Connect(function(player)
    local policy = PolicyAdapter:GetPolicy(player)
    local ev = Remotes.get("UX_Policy")
    if ev then ev:FireClient(player, policy) end
end)

-- Initialize services
DataService:Init()
CommerceService:Init()

-- Autosave
local Autosave = require(script.Parent.Systems.ProfileAutosaveSystem)
Autosave.Start(60)
