# Resource Inventory + Deposit MVP Validation

This repository's shell test runner is currently placeholder-only, so this checklist captures Roblox Studio validation for the server-authoritative resource inventory and deposit slice.

## Studio validation steps

1. Open/sync the project with Rojo (`rojo serve default.project.json`) or build the place file and open it in Roblox Studio.
2. Start a local Roblox Studio server with one player.
3. Confirm `InventoryService` initializes without errors after `RemoteService`, `BeaconService`, and `PhaseService`.
4. Confirm `ReplicatedStorage/Remotes` contains server-created `ResourceStateChanged` and `RequestDepositResource` remotes.
5. Confirm the player receives starter resources only when `Constants.DEV_GRANT_STARTER_RESOURCES` is enabled.
6. Confirm `ResourceStateChanged` reaches the client and the `ResourceHUD` displays personal carried resources and shared team resources.
7. Stand near the Beacon and press **Deposit All**; confirm Wood, Scrap, Food, and Fuel transfer from the player's personal carry inventory into team storage.
8. From the server console, call `InventoryService.DepositResource(player, "Wood")` after granting Wood and confirm Wood moves from personal inventory to team inventory.
9. From the server console, call `InventoryService.DepositAll(player)` after granting multiple resources and confirm all depositable resources transfer.
10. Confirm invalid resource types such as `"Shards"`, `"Gold"`, or `nil` are rejected and do not mutate team storage.
11. Confirm negative, zero, NaN, and non-number amounts are rejected and do not mutate team storage.
12. Confirm the client cannot directly mutate team inventory; the client only fires `RequestDepositResource` and receives read-only `ResourceStateChanged` snapshots.
13. Confirm no building, crafting, gathering nodes, combat, enemies, persistence, DataStore, monetization, cosmetics, procedural maps, or full inventory screen were added in this PR.

## Current skipped validation warnings

- `rojo build default.project.json --output build.rbxlx` may be skipped when Rojo is not installed in PATH.
- `stylua --check .` may be skipped when Stylua is not installed in PATH.
- `selene .` may be skipped when Selene is not installed in PATH.
- `./scripts/run-tests.sh` is currently a placeholder and does not execute real TestEZ/Luau tests yet.

## Deferred checks

- Beacon-proximity deposit validation currently uses the runtime Beacon part/model and the player's `HumanoidRootPart`; broader deposit locations such as storage crates and builder stations remain future work.
- Starter resource grants are development-only and controlled by `Constants.DEV_GRANT_STARTER_RESOURCES`; replace or disable this path when server-authoritative gathering is implemented.
