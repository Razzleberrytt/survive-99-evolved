# Survive-99-Evolved Starter Pack

Drop these folders into your Rojo-mapped project:
- `Shared/Net`, `Shared/Config`, `Shared/Types`
- `Server/Net`, `Server/Services`, `Server/Systems`, `Server/init.server.lua`
- `Client/Systems`, `Client/init.client.lua`
- `Tests/*` (TestEZ)

## Wire persistence
In `Server/Services/DataService.lua`, choose one:
```lua
-- local Profile = require(game.ServerStorage.Vendor.ProfileService)
-- local Profile = require(game.ServerStorage.Vendor.ProfileStore)
```
Keep the same API; the rest of the game code doesn't change.

## Remotes
Created on server startup:
- Inbound: `Input_Fire`, `Input_Attack`, `Input_Revive`, `Menu_RequestPurchase`
- Outbound: `State_DamageApplied`, `State_WaveUpdate`, `Economy_Balance`, `UX_Policy`

## Dev products (seed)
Configured in `Shared/Config/Products.lua`:
- 1001 Revive Token
- 2001 Coins 500
- 2002 Coins 1200

Replace with your real product IDs in production.

## Autosave
`Server/Systems/ProfileAutosaveSystem.lua` saves active profiles every ~60s (with jitter).

## Tests
Example TestEZ specs are provided. Hook them into your CI or run in Studio with a simple runner.

---

Happy building!
