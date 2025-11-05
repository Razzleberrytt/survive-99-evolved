local Remotes = require(game.ServerScriptService.Net.Remotes)
local V = require(game.ReplicatedStorage.Shared.Net.Validators)
local AdminGuard = require(game.ServerScriptService.Security.AdminGuard)
local Schemas = require(game.ReplicatedStorage.Shared.Admin.ActionSchemas)
local Actions = require(game.ServerScriptService.Admin.Actions)
local Audit = require(game.ServerScriptService.Logs.AdminAudit)

local function schemaFor(name) return Schemas[name] end

Remotes.registerEvent(
  "Admin_Perform",
  V.shape({ action = V.string, payload = V.table }),
  function(player, body)
    local actorId = player.UserId
    local name = body.action
    local schema = schemaFor(name)
    if not schema then return Audit.log(name, actorId, body.payload, false, "unknown_action") end
    if not schema(body.payload) then return Audit.log(name, actorId, body.payload, false, "invalid_payload") end
    local fn = Actions[name]
    local ok, res = pcall(fn, { actorId = actorId, payload = body.payload })
    Audit.log(name, actorId, body.payload, ok, ok and "ok" or tostring(res))
  end,
  { permission = AdminGuard, capacity = 6, refill = 1 }
)
