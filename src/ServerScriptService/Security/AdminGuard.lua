local Players = game:GetService("Players")
local Admins = require(game.ReplicatedStorage.Shared.Config.Admins)

local ALLOW = {}
for _, id in ipairs(Admins.Allowlist or {}) do
  if type(id) == "number" then
    ALLOW[id] = true
  end
end

local function inGroup(userId: number?)
  if type(userId) ~= "number" then
    return false
  end
  local groupConfig = Admins.Group
  if groupConfig and groupConfig.GroupId and groupConfig.GroupId > 0 then
    local ok, rank = pcall(function()
      return Players:GetRankInGroupAsync(userId, groupConfig.GroupId)
    end)
    if ok and rank and rank >= (groupConfig.MinRank or 255) then
      return true
    end
  end
  return false
end

local function resolveUserId(subject): number?
  if typeof(subject) == "Instance" then
    return subject.UserId
  end
  return subject
end

local AdminGuard = {}

function AdminGuard.isUserIdAllowed(userId: number?)
  if type(userId) ~= "number" then
    return false
  end

  if ALLOW[userId] then
    return true
  end

  if inGroup(userId) then
    return true
  end

  return false
end

function AdminGuard.isPlayerAllowed(player: Player?)
  if player == nil then
    return false
  end
  return AdminGuard.isUserIdAllowed(player.UserId)
end

setmetatable(AdminGuard, {
  __call = function(_, subject)
    return AdminGuard.isUserIdAllowed(resolveUserId(subject))
  end,
})

return AdminGuard
