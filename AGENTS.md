# AGENTS.md — Survive 99: Evolved

## Project overview

Survive 99: Evolved is a mobile-first Roblox co-op survival/base-defense game. Players protect a central Beacon through a 99-night campaign by gathering resources, building defenses, fighting waves, reviving teammates, resolving omens, defeating bosses, and earning fair long-term rewards.

`SPEC.md` is the canonical product, design, technical, and implementation source of truth. When implementation conflicts with `SPEC.md`, prefer the spec unless Roblox platform policy, safety, or security requires a safer alternative. Document any intentional deviation in the PR.

## Repo layout

- `SPEC.md` — canonical game specification and implementation roadmap.
- `README.md` — setup, build, validation, and milestone overview.
- `default.project.json` — Rojo project file mapping Roblox services to `src/`.
- `src/ReplicatedStorage/Shared` — shared constants, configs, types, client/server-safe utilities, and remote names.
- `src/ReplicatedStorage/Shared/Config` — centralized tuning data for roles, resources, structures, enemies, omens, bosses, economy, cosmetics, and feature flags.
- `src/ReplicatedStorage/Shared/Remotes` — shared remote documentation/placeholders; server code must create and validate runtime remotes.
- `src/ServerScriptService/Services` — server-authoritative domain services.
- `src/ServerScriptService/Systems` — focused server systems when systems are preferable to service APIs.
- `src/StarterPlayer/StarterPlayerScripts` — client UI, input, camera, feedback, and presentation scripts.
- `src/StarterGui` — Rojo-mapped UI assets and ScreenGuis when added.
- `test/` and `Tests/` — existing test specs. Preserve useful tests while converging on one test layout in a dedicated PR.
- Legacy root folders (`Client/`, `Server/`, `Shared/`) contain earlier starter code. Do not delete them casually; migrate or remove them only in focused cleanup PRs after confirming equivalent `src/` coverage.

## Roblox, Rojo, and Luau conventions

- Keep code idiomatic Luau with clear module boundaries and typed annotations where they improve safety.
- Prefer small ModuleScripts that return tables/functions; avoid global state except for Roblox services obtained through `game:GetService`.
- Keep shared config data centralized under `src/ReplicatedStorage/Shared/Config`.
- Keep constants in `src/ReplicatedStorage/Shared/Constants.lua` only when they are broadly shared. Feature-specific tuning belongs in config modules.
- Server services should validate all client requests and own all trusted state changes.
- Client scripts should handle input, UI, animation, audio, camera, and prediction/presentation only.
- Remote names and payload shapes should be defined centrally before use.
- Use Rojo paths from `default.project.json`; do not add new top-level source roots without updating documentation and project mapping.
- Never put try/catch-style wrappers around imports.

## Server-authoritative rule

Combat, resources, building, rewards, purchases, player health, revives, Beacon state, enemy spawning, wave outcomes, and persistence must be validated and finalized server-side. Clients may request actions and render feedback, but must never be trusted for damage, placement legality, currency balances, inventory changes, purchase grants, or saved data.

## Mobile-first rule

UI and controls must be readable and usable on phones first. Use large touch targets, short labels, clear contrast, safe-area awareness, simple input flows, and scalable HUD layouts. Desktop and gamepad support should not compromise mobile usability.

## Monetization rule

No pay-to-win systems. Monetization must focus on cosmetics, emotes, titles, optional convenience that does not create competitive or survival power, private-server/social features, or clearly fair battle-pass style rewards. Never add placeholder purchases or product grants without policy review and server receipt validation.

## Do-not rules

Do not:

- Implement the entire 99-night game in one PR.
- Add fake production DataStore code or claim persistence is production-safe without real validation and tests.
- Add client-authoritative combat, building, resources, rewards, purchases, player health, or persistence.
- Add monetization products before the product design and receipt validation are ready.
- Add complex procedural generation before core loops are playable.
- Add unnecessary dependencies or toolchains.
- Delete existing implementation files unless they are confirmed duplicate placeholders and the PR explains why.
- Hide validation failures or claim tests passed unless the exact command ran successfully.

## How to run validation

Use existing tooling when available:

```sh
rojo build default.project.json --output build.rbxlx
stylua --check .
selene .
./scripts/run-tests.sh
```

If a tool is not installed in the environment, report it as a warning instead of inventing a new dependency. Recommended future tools are Rojo, Aftman, Stylua, Selene or luau-lsp, and Wally only when package dependencies are actually needed.

## How future agents should use SPEC.md

1. Read `SPEC.md` before changing gameplay, economy, networking, persistence, UI, or monetization.
2. Identify the smallest milestone slice that satisfies the requested task.
3. Update or add centralized config first when implementing spec-backed content.
4. Implement server authority before client presentation for trusted gameplay systems.
5. Add or update tests for changed behavior when practical.
6. Note any spec ambiguity, tradeoff, or intentional deviation in the PR body.

## Small-PR rule

Future work should be split into focused PRs. Prefer one gameplay system, one config expansion, one UI flow, one validation layer, or one cleanup at a time. Avoid mixing refactors, feature work, monetization, and cosmetic changes in the same PR.

## Definition of done

A PR is done when:

- The change is scoped to the requested task and aligned with `SPEC.md`.
- Trusted gameplay state remains server-authoritative.
- Shared config and constants are centralized and documented where needed.
- Mobile UI/control changes are usable on phone-sized screens.
- Validation commands were run when available, with exact results reported.
- New warnings, limitations, and follow-up work are called out honestly.
- No unnecessary dependencies, duplicate docs, or fake-complete placeholder systems were added.
