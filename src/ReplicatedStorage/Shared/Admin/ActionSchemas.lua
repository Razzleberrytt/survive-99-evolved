local V = require(game.ReplicatedStorage.Shared.Net.Validators)

local optional = V.optional

-- Define allowed admin actions and their payload validators.
return {
  _probe = V.shape({}),

  ToggleDoubleXP = V.shape({ enabled = V.boolean }),
  GiveCurrency = V.shape({ userId = V.integer, amount = V.integer }),
  SpawnWave = V.shape({ count = V.integer, kind = V.string }),

  spawn_miniboss = V.shape({}),
  spawn_wave = V.shape({
    squads = optional(V.array(V.shape({
      type = V.string,
      count = V.integer,
    }))),
  }),
  fuel_plus = V.shape({ amount = optional(V.integer) }),
  blackout = V.shape({}),
  give_shards = V.shape({ amount = optional(V.integer) }),
  reset_tutorial = V.shape({ targetUserId = optional(V.integer) }),

  set_flag = V.shape({
    key = V.string,
    value = optional(V.any),
  }),

  set_tuning = V.shape({
    key = V.string,
    value = optional(V.any),
  }),
}
