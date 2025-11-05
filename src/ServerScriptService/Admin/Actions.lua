local Actions = {}

-- NOTE: Replace stubs with your real systems (LiveConfigService, EconomyService, Spawner, etc.)
Actions.ToggleDoubleXP = function(ctx)
  -- ctx = { actorId, payload = { enabled = bool } }
  -- LiveConfigService.set("doubleXP", ctx.payload.enabled, ctx.actorId)
  return true
end

Actions.GiveCurrency = function(ctx)
  -- Validate target exists, then mutate on server economy service
  -- EconomyService.add(ctx.payload.userId, ctx.payload.amount, "admin_grant", ctx.actorId)
  return true
end

Actions.SpawnWave = function(ctx)
  -- Spawner.spawn(ctx.payload.kind, ctx.payload.count)
  return true
end

return Actions
