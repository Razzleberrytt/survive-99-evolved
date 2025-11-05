local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AdminConfig = require(ReplicatedStorage.Shared.Config.Admins)

local allowSet: { [number]: boolean } = {}
for _, userId in ipairs(AdminConfig.Allowlist or {}) do
  allowSet[userId] = true
end

local AdminGuard = {}

function AdminGuard.isUserIdAllowed(userId: number?): boolean
  if type(userId) ~= "number" then
    return false
  end
  return allowSet[userId] == true
end

function AdminGuard.isPlayerAllowed(player: Player?): boolean
  if player == nil then
    return false
  end
  return AdminGuard.isUserIdAllowed(player.UserId)
end

setmetatable(AdminGuard, {
  __call = function(_, player: Player)
    return AdminGuard.isPlayerAllowed(player)
  end,
})

return AdminGuard
