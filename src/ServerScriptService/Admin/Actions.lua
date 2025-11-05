local Players = game:GetService("Players")
local Services = game.ServerScriptService.Services

local LiveConfigAdmin = require(Services.LiveConfigAdmin)
local AISpawner = require(Services.AISpawnerService)
local BeaconService = require(Services.BeaconService)
local DataService = require(Services.DataService)
local TutorialService = require(Services.TutorialService)

local function findPlayer(userId: number?)
  if type(userId) ~= "number" then
    return nil
  end
  for _, player in ipairs(Players:GetPlayers()) do
    if player.UserId == userId then
      return player
    end
  end
  return nil
end

local function clampAmount(amount, minValue, maxValue)
  amount = tonumber(amount) or 0
  return math.clamp(amount, minValue, maxValue)
end

local Actions = {}

Actions["_probe"] = function(_ctx)
  return true
end

Actions.ToggleDoubleXP = function(ctx)
  return LiveConfigAdmin.SetFlag(ctx.actorId, "doubleXP", ctx.payload.enabled)
end

Actions.GiveCurrency = function(ctx)
  local userId = ctx.payload.userId
  local target = findPlayer(userId)
  if not target then
    return false, "player_not_found"
  end

  local amount = clampAmount(ctx.payload.amount, -1_000_000, 1_000_000)
  if amount == 0 then
    return false, "zero_amount"
  end

  DataService.AddShards(target, amount)
  return true
end

Actions.SpawnWave = function(ctx)
  local count = clampAmount(ctx.payload.count, 1, 50)
  local kind = ctx.payload.kind
  AISpawner.spawn({ budget = count, squads = { { type = kind, count = count } } })
  return true
end

Actions.spawn_miniboss = function(_ctx)
  AISpawner.spawn({ budget = 1, squads = { { type = "Miniboss", count = 1 } } })
  return true
end

Actions.spawn_wave = function(ctx)
  local plan = ctx.payload.squads
  if type(plan) == "table" and #plan > 0 then
    AISpawner.spawn({ budget = 0, squads = plan })
  else
    AISpawner.spawn({
      budget = 99,
      squads = {
        { type = "Forager", count = 6 },
        { type = "Bruiser", count = 3 },
      },
    })
  end
  return true
end

Actions.fuel_plus = function(ctx)
  local amount = clampAmount(ctx.payload.amount or 20, -200, 200)
  BeaconService.ApplyFuel(amount)
  return true
end

Actions.blackout = function(_ctx)
  BeaconService.ApplyFuel(-200)
  return true
end

Actions.give_shards = function(ctx)
  local amount = clampAmount(ctx.payload.amount or 50, 0, 10_000)
  DataService.AddShards(ctx.player, amount)
  return true
end

Actions.reset_tutorial = function(ctx)
  local targetUserId = ctx.payload.targetUserId or ctx.actorId
  local target = findPlayer(targetUserId)
  if not target then
    return false, "player_not_found"
  end

  local profile = DataService.GetProfileSnapshot(target) or DataService.LoadProfileAsync(target)
  if profile then
    profile.tutorialComplete = nil
  end
  TutorialService.Begin(target)
  return true
end

Actions.set_flag = function(ctx)
  return LiveConfigAdmin.SetFlag(ctx.actorId, ctx.payload.key, ctx.payload.value)
end

Actions.set_tuning = function(ctx)
  return LiveConfigAdmin.SetTuning(ctx.actorId, ctx.payload.key, ctx.payload.value)
end

return Actions
