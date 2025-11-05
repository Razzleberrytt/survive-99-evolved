local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = require(script.Parent.Remotes)
local Validators = require(ReplicatedStorage.Shared.Net.Validators)
local AdminGuard = require(game.ServerScriptService.Security.AdminGuard)

Remotes.registerEvent(
  "ReportHit",
  Validators.shape({
    targetId = Validators.integer,
    weaponId = Validators.string,
    hitPos = Validators.Vector3,
  }),
  function(player, payload)
    -- TODO: validate that targetId matches a server-tracked entity.
    -- TODO: confirm that player owns weaponId and meets positional checks.
    -- Damage is computed server-side; do not trust client provided values.
    -- DamageService.Apply(targetId, computedDamage)
  end,
  { capacity = 12, refill = 3 }
)

