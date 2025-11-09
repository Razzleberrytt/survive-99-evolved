# Survive 99: Evolved
[![CI](https://github.com/Razzleberrytt/survive-99-evolved/actions/workflows/ci.yml/badge.svg)](../../actions)
**Phase 3**: server policy/age gating, UI purchase guard, policy-aware ProcessReceipt, `/policycheck`, and `/navpreset base-safe`.
- Docs: [Playtest](docs/PLAYTEST.md) • [Release](docs/RELEASE.md)

# Survive 99: Evolved
[![CI](https://github.com/Razzleberrytt/survive-99-evolved/actions/workflows/ci.yml/badge.svg)](../../actions)
A Rojo/Wally Roblox project for a survive-the-night co-op experience with live-ops toggles and soft-launch discipline.
- **Docs:** [Playtest](docs/PLAYTEST.md) • [Release](docs/RELEASE.md)

# Survive-99-Evolved
Mobile-first co-op survive-the-night game on Roblox.

## Dev Setup
- Install Aftman & Rojo plugin: https://rojo.space/
- Install Wally: https://wally.run/
- Commands:
  - `wally install`
  - `rojo serve` and open the project in Roblox Studio
- Tests are under `ReplicatedStorage/Tests` with a simple TestEZ runner.

## Publish Checklist (Soft Launch)
- Studio > Game Settings:
  - Basic: Name, Description, Genre, Age rating (target 9+ or All Ages).
  - Icon & Thumbnails: Use `/icon` and `/thumbs` helpers to frame shots.
  - Permissions: Public (soft-launch ON) or Private for QA.
  - Monetization: Add DevProducts/GamePasses; paste IDs into `Config/Store.lua`.
- Test:
  - Run `/shipcheck` in Play mode (Output prints ✔/✖).
  - Mobile device test (60 fps target).
  - Verify Policy gates (under-13: no IAP/ads; soft-launch regions).
- Go Live:
  - Toggle `FeatureFlags.softLaunch=false` in MemoryStore `Survive99_LiveConfig_v1/live`.
  - Push new thumbnails, description with seasonal hook.
  - Monitor Analytics: `soft_gate_blocked`, `purchase_result`, heartbeat p95.

## Final Polish Tools
- **Radial Build Menu**: Tap **Build** (bottom-left) → pick a piece → tap world to place.
- **Performance Overlay**: Top-right shows **FPS** and **RTT** (round-trip to server).
- **Credits**: Type `/credits` in chat to toggle. Edit text in `Shared/Config/Credits.lua`.
- **Confetti Egg**: `/confetti` or `/egg` (client-only).
- **Icon helpers**: `/icon`, `/thumbs`. **Ship check**: `/shipcheck`.

## Admin & Release Tools
- **Admin Panel (dev-only)**: Add your userId in `Services/LiveConfigAdmin.lua`. In Play, panel appears (top-right). You can:
  - Toggle `softLaunch` OFF
  - Set tuning like `waveCap` to 100
  - Spawn wave/miniboss, add fuel, blackout, grant shards, reset tutorial
- **Icon Scene**: Type `/iconscene`, then `/iconA`, `/iconB`, `/iconC` to frame shots. Use Studio Screenshot.
- **Release Commands**: `/shipcheck` (readiness), `/release` (final checklist).
- **LiveConfig**: Server writes overrides to MemoryStore key `Survive99_LiveConfig_v1/live`.

## Audit & Hardening
- In Studio (Play), type **/audit**. Output prints ✅/❌ for:
  - StreamingEnabled, Replicated folders, Remotes, Systems, Actors, Physics groups, LiveConfig/Tuning, DataService
  - A short Heartbeat perf probe
- Remote rate monitor logs warnings if a client spams **NightStartVote**.
- Keep `RemoteWatch.server.lua` around in soft-launch, then disable if too noisy.

## Atmosphere & Art Swap Pack
- Presets live in `Shared/Config/Atmosphere.lua` (`Eerie`, `Dusk`, `Clear`). Omen effects tweak fog/bloom/clock.
- Client applies presets automatically; accessibility “Reduce Flashes” trims bloom/DOF.
- Ambient loops adjust by phase/omen (`Ambience.client.lua`). Replace SoundIds.
- Enemy models: place under `ReplicatedStorage/Assets/Models/Enemies/<Kind>/Rig`. Fallback is a Part.
- Dev commands:
  - `/mood Eerie|Dusk|Clear` — cycle local preset (server pushes on night/day).
  - `/preset` — print current preset.
- Performance tips: keep texture resolutions modest (≤1024), avoid >100 active point lights, ensure enemy models have a single PrimaryPart.

## Spawn Points & Nav Volumes
- **Spawn Points** live under `Workspace/SpawnPoints` (Parts tagged `EnemySpawn`). We auto-generate a 24-point ring if empty. Move/add/delete markers to control where enemies come from.
- **Nav Volumes** live under `Workspace/NavVolumes`. Set a Part’s attribute `Nav="Block"` to forbid navmesh through it, or `Nav="HighCost"` to allow but discourage. We automatically attach `PathfindingModifier`s.
- **Costs**: `HighCost` has cost **2.0** (see `S_PathfindAI`). Tweak as needed.
- **Tools**:
  - `/navviz` — toggle gizmos for spawn points (spheres) and nav volumes (boxes).
  - `/genspawns` — Studio convenience: rebuild default ring (deletes & recreates SpawnPoints).

## Spawner Logic
- Spawner asks `SpawnPointService.GetValidatedSpawn(minLen)` for a point whose path length to the Beacon exceeds `minLen` (default 80 studs) so enemies don’t pop right at the base.
- Pathfinding respects `HighCost` areas and avoids `Block` volumes.