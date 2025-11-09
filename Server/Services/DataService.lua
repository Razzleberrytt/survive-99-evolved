local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- NOTE: Wire your chosen persistence module here. Keep the API surface identical.
-- local Profile = require(game.ServerStorage.Vendor.ProfileService)
-- local Profile = require(game.ServerStorage.Vendor.ProfileStore)

local TEMPLATE = {
    ver = 1, userId = 0,
    coins = 0, premium = 0, xp = 0, level = 1,
    inventory = { cosmetics = { skins = {}, emotes = {} }, revives = 0 },
    settings = { sensitivity = 0.5, aimAssist = true, lang = "en" },
    achievements = {}, dailies = { seed = 0, progress = {} },
    receipts = {}, policy = { ageGroup = "Unknown", canTrade = false, canGacha = false },
    createdAt = 0, updatedAt = 0,
}

local DataService = {}
DataService._profiles = {}

function DataService:Init()
    if not Profile then
        warn("[DataService] Profile module not wired; using in-memory mock (NOT FOR PRODUCTION).")
        self._mock = true
        self._mem = {}
    else
        self._store = Profile.GetProfileStore("PlayerData_v1", TEMPLATE)
    end

    Players.PlayerAdded:Connect(function(p) self:_onPlayerAdded(p) end)
    Players.PlayerRemoving:Connect(function(p) self:_onPlayerRemoving(p) end)
end

function DataService:_onPlayerAdded(player)
    if self._mock then
        local copy = table.clone(TEMPLATE)
        copy.userId = player.UserId
        copy.createdAt = os.time()
        copy.updatedAt = os.time()
        self._profiles[player] = { Data = copy, _mock = true }
        return
    end

    local profile = self._store:LoadProfileAsync("player:"..player.UserId, "ForceLoad")
    if not profile then return player:Kick("Data load error") end
    profile:AddUserId(player.UserId)
    profile:Reconcile()
    profile.Data.userId = player.UserId
    profile.Data.createdAt = profile.Data.createdAt == 0 and os.time() or profile.Data.createdAt
    profile.Data.updatedAt = os.time()
    profile:ListenToRelease(function()
        self._profiles[player] = nil
        player:Kick("Session released")
    end)
    if player.Parent ~= Players then profile:Release() return end
    self._profiles[player] = profile
end

function DataService:_onPlayerRemoving(player)
    local profile = self._profiles[player]
    if not profile then return end
    if profile._mock then
        self._profiles[player] = nil
        return
    end
    profile.Data.updatedAt = os.time()
    profile:Release()
end

function DataService:WithProfile(player, fn)
    local profile = self._profiles[player]
    if not profile then return false, "no-profile" end
    local ok, err = pcall(fn, profile.Data)
    if ok then
        profile.Data.updatedAt = os.time()
        if profile._mock then
            -- nothing
        else
            -- defer save to autosave system
        end
    end
    return ok, err
end

function DataService:IterProfiles(callback)
    for plr, profile in pairs(self._profiles) do
        callback(plr, profile)
    end
end

return DataService
