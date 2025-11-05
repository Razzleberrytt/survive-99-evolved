local Remotes = require(game.ServerScriptService.Net.Remotes)
local AdminGuard = require(game.ServerScriptService.Security.AdminGuard)
local V = require(game.ReplicatedStorage.Shared.Net.Validators)
local ActionSchemas = require(game.ReplicatedStorage.Shared.Admin.ActionSchemas)
local Actions = require(script.Parent.Actions)
local Audit = require(game.ServerScriptService.Logs.AdminAudit)

local function coercePayload(payload)
  if type(payload) ~= "table" then
    return {}
  end

  local copy = {}
  for key, value in pairs(payload) do
    copy[key] = value
  end
  return copy
end

local function validateRequest(request)
  if type(request) ~= "table" then
    return false
  end

  local actionName = request.action
  if type(actionName) ~= "string" then
    return false
  end

  local validator = ActionSchemas[actionName]
  if type(validator) ~= "function" then
    return false
  end

  local payload = request.payload
  if payload ~= nil and type(payload) ~= "table" then
    return false
  end

  return validator(coercePayload(payload)) == true
end

local function onDenied(player)
  local actorId = player and player.UserId or 0
  Audit.log("_denied", actorId, nil, false, "not_admin")
  return false, "not_admin"
end

local function onRateLimit(player)
  local actorId = player and player.UserId or 0
  Audit.log("_rate_limit", actorId, nil, false, "rate_limited")
  return false, "rate_limited"
end

local function onInvalid(player, payload)
  local actionName = "invalid"
  if type(payload) == "table" and type(payload.action) == "string" then
    actionName = payload.action
  end

  Audit.log(actionName, player.UserId, payload, false, "bad_payload")
  return false, "bad_payload"
end

local function perform(player, request)
  local actorId = player.UserId
  local actionName = request.action
  local payload = coercePayload(request.payload)

  local handler = Actions[actionName]
  if type(handler) ~= "function" then
    Audit.log(actionName, actorId, payload, false, "action_not_supported")
    return false, "action_not_supported"
  end

  local ok, packed = pcall(function()
    return table.pack(handler({
      actorId = actorId,
      payload = payload,
      player = player,
    }))
  end)

  if not ok then
    Audit.log(actionName, actorId, payload, false, packed)
    warn(string.format("[Admin_Perform] handler error for %s: %s", actionName, packed))
    return false, "handler_error"
  end

  local success = packed[1]
  if success ~= true then
    local reason = packed[2]
    if type(reason) ~= "string" then
      reason = "failed"
    end
    Audit.log(actionName, actorId, payload, false, reason)
    return false, reason
  end

  local response = {}
  for i = 2, packed.n do
    response[i - 1] = packed[i]
  end

  Audit.log(actionName, actorId, payload, true, response[1])
  if #response > 0 then
    return true, table.unpack(response)
  end
  return true
end

local REQUEST_SCHEMA = V.shape({
  action = V.string,
  payload = V.optional(V.table),
})

local requestSchema = function(payload)
  return REQUEST_SCHEMA(payload) and validateRequest(payload)
end

Remotes.registerFunction(
  "Admin_Perform",
  requestSchema,
  perform,
  {
    permission = AdminGuard,
    capacity = 4,
    refill = 0.5,
    onDenied = onDenied,
    onInvalid = onInvalid,
    onRateLimit = onRateLimit,
  }
)
