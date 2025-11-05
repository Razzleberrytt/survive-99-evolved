local V = require(game.ReplicatedStorage.Shared.Net.Validators)
return {
  -- Start with one action so it’s easy to test.
  ToggleDoubleXP = V.shape({ enabled = V.boolean }),
}
