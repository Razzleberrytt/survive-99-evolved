local V = require(game.ReplicatedStorage.Shared.Net.Validators)

-- Define allowed admin actions and their payload validators.
return {
  ToggleDoubleXP = V.shape({ enabled = V.boolean }),
  GiveCurrency = V.shape({ userId = V.integer, amount = V.integer }),
  SpawnWave = V.shape({ count = V.integer, kind = V.string }),
}
