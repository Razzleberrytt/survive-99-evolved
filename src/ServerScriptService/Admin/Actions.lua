local Actions = {}
-- Minimal stub: wire to your real systems later.
Actions.ToggleDoubleXP = function(ctx)
  -- ctx.payload.enabled (boolean)
  -- TODO: integrate with LiveConfig when you add it
  print("[ADMIN] DoubleXP =>", ctx.payload.enabled, "by", ctx.actorId)
  return true
end
return Actions
