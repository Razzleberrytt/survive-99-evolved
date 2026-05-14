# Phase + Beacon MVP Validation

This repository's shell test runner is currently a placeholder, so this checklist captures Roblox Studio validation for the first server-authoritative phase/beacon loop.

## Studio validation steps

1. Open the place from Rojo (`rojo serve default.project.json`) or build/sync the project into Roblox Studio.
2. Start a local Roblox Studio test server with at least one client.
3. Confirm the server initializes `RemoteService`, `BeaconService`, and `PhaseService` without errors.
4. Confirm `ReplicatedStorage/Remotes` contains server-created `PhaseStateChanged`, `BeaconStateChanged`, and `RequestNightStartVote` remotes.
5. Confirm phase state progresses through `Lobby -> Day -> Dusk -> Night -> Dawn -> Day`.
6. Confirm the `PhaseBeaconHUD` client display receives `PhaseStateChanged` and shows the current phase, night number, and countdown.
7. Confirm the client receives `BeaconStateChanged` and shows Beacon HP/shield.
8. From the server console, call BeaconService methods to confirm clamping:
   - `Damage(amount)` reduces shield first, then HP.
   - `Heal(amount)` clamps HP at max HP.
   - `SetHealth(value)` clamps HP between `0` and `maxHp`.
   - `SetShield(value)` clamps shield between `0` and `maxShield`.
9. Confirm no client script directly mutates phase or beacon state; clients only listen to read-only remote updates.

## Current skipped validation warnings

- `rojo build default.project.json --output build.rbxlx` may be skipped when Rojo is not installed in PATH.
- `stylua --check .` may be skipped when Stylua is not installed in PATH.
- `selene .` may be skipped when Selene is not installed in PATH.
- `./scripts/run-tests.sh` is currently a placeholder and does not execute real TestEZ/Luau tests yet.
