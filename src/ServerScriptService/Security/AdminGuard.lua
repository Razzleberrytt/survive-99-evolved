local Admins = require(game.ReplicatedStorage.Shared.Config.Admins)
local ALLOW = {}
for _, id in ipairs(Admins.Allowlist) do ALLOW[id] = true end
return function(subject)
  local userId = typeof(subject) == "Instance" and subject.UserId or subject
  return ALLOW[userId] == true
end
