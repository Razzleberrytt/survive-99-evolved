# Survive 99: Evolved

Survive 99: Evolved is a mobile-first Roblox co-op survival/base-defense game. Players defend a central Beacon across a 99-night campaign by gathering resources during the day, building and repairing defenses, fighting escalating enemy waves at night, reviving teammates, countering omens, defeating bosses, and earning fair cosmetic/progression rewards.

The canonical product and implementation reference is [`SPEC.md`](SPEC.md). Future feature work should start by reading that file and implementing small, server-authoritative slices of the roadmap.

## Current repository state

This is an existing Roblox/Rojo Luau project with both:

- A canonical Rojo `src/` tree mapped by `default.project.json`.
- Legacy starter roots (`Client/`, `Server/`, `Shared/`) and existing test folders (`test/`, `Tests/`) that should be preserved until a focused migration/cleanup PR confirms what is still useful.

This project now includes the first tightly scoped server-authoritative loop: `RemoteService` creates named read-only remotes, `BeaconService` owns Beacon HP/shield/fuel state, and `PhaseService` advances through Lobby/Day/Dusk/Night/Dawn for client display. It still intentionally does **not** implement the full game.

## Expected tools

Recommended local tools:

- [Rojo](https://rojo.space/) for syncing/building the Roblox place.
- [Aftman](https://github.com/LPGhatguy/aftman) for tool version management, if the project standardizes on it.
- Stylua for formatting, optional until enforced by CI.
- Selene or luau-lsp for Luau linting/static checks, optional until enforced by CI.
- Wally only when the project actually needs package dependencies.

Do not add new dependencies just to satisfy a one-off task.

## Development setup

1. Install Roblox Studio.
2. Install Rojo and any project-standard tools available through `aftman.toml`.
3. Clone the repository.
4. From the repository root, start Rojo:

   ```sh
   rojo serve default.project.json
   ```

5. In Roblox Studio, connect using the Rojo plugin.

To build a place file instead of syncing live:

```sh
rojo build default.project.json --output build.rbxlx
```

## Folder structure

```text
.
├── SPEC.md                         # Canonical game specification
├── AGENTS.md                       # Instructions for future coding agents
├── README.md                       # Project setup and roadmap
├── default.project.json            # Rojo project mapping to src/
├── src/
│   ├── ReplicatedStorage/
│   │   └── Shared/
│   │       ├── Constants.lua
│   │       ├── Config/
│   │       │   ├── Roles.lua
│   │       │   ├── Resources.lua
│   │       │   ├── Structures.lua
│   │       │   ├── Enemies.lua
│   │       │   ├── Omens.lua
│   │       │   └── Bosses.lua
│   │       └── Remotes/RemoteNames.lua
│   ├── ServerScriptService/
│   │   ├── Services/
│   │   └── Systems/
│   ├── StarterPlayer/
│   │   └── StarterPlayerScripts/
│   └── StarterGui/
├── test/                           # Existing Luau test specs
├── Tests/                          # Existing TestEZ-style specs
├── Client/ Server/ Shared/         # Legacy starter roots; preserve until migrated
└── scripts/                        # Existing utility scripts
```

## Validation

Run the available validation commands for your environment. For the phase/beacon MVP, also follow [`docs/VALIDATION_PHASE_BEACON.md`](docs/VALIDATION_PHASE_BEACON.md) in Roblox Studio because the current shell test runner is a placeholder.

```sh
rojo build default.project.json --output build.rbxlx
stylua --check .
selene .
./scripts/run-tests.sh
```

If a command is unavailable locally, install the project-standard tool or report the limitation. Do not claim a validation passed unless the command actually ran successfully.

## Implementation principles

- Use `SPEC.md` as the source of truth for game design, systems, economy, networking, persistence, and roadmap decisions.
- Keep gameplay authority on the server for combat, resources, building, rewards, purchases, player health, revives, Beacon state, waves, and persistence.
- Treat client code as UI/input/presentation/prediction only.
- Keep config and constants centralized in `src/ReplicatedStorage/Shared`.
- Build for mobile first: readable UI, large touch targets, simple controls, and safe-area-aware layouts.
- Keep monetization fair and non-pay-to-win.
- Prefer small focused PRs over broad rewrites.

## Milestone roadmap

1. **Foundation** — canonical docs, Rojo mapping, shared constants, and core config modules.
2. **Core loop prototype** — day/night state machine and Beacon health/fuel are started; simple gathering and server-validated building requests remain future small PRs.
3. **Combat prototype** — server-authoritative enemy spawning, player attacks, damage, revives, and basic wave resolution.
4. **Base defense** — structures, traps, repairs, placement validation, and mobile build UI.
5. **Progression and rewards** — fair run rewards, cosmetics-first persistence, analytics hooks, and anti-exploit checks.
6. **Omens, bosses, and events** — spec-backed modifiers and milestone encounters added incrementally.
7. **Polish and launch readiness** — performance budgets, playtest feedback, policy review, CI validation, and release documentation.

## Recommended next Codex task

Implement MVP team resource inventory + deposit service, without building placement yet.
