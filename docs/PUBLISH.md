# Survive-99 Evolved — Publish Guide (MVP)

## Preflight (in Studio, Play mode)
- Type `/audit` → all ✅.
- Type `/shipcheck` → fix any ❌.
- Type `/release` → read the actions list.

## Icons & Thumbnails
1. In chat: `/iconscene` then `/iconA`, `/iconB`, `/iconC`.
2. Studio: File → Screenshot for icon/three thumbs.
3. Game Settings → Icon/Thumbnails → upload.

## Monetization (optional now)
- Game Settings → Monetization → add Dev Products (e.g., 100 Shards).
- Put IDs in `src/ReplicatedStorage/Shared/Config/Store.lua` (DevProducts).
- In Play, press **Shop** (HUD) to confirm prompt opens.

## Soft Launch
- Keep `softLaunch=true` in `Shared/Config/FeatureFlags.lua`, or set via Admin Panel.
- Regions: edit `softLaunchRegions` or add your userId to `whitelistUserIds`.
- Verify a non-whitelisted alt gets kicked with the soft-launch message.

## Go Live (flip the switch)
- Admin Panel → `softLaunch OFF` (or MemoryStore key `Survive99_LiveConfig_v1/live`).
- Game Settings → Basic: fill **Name**, **Description**, **Genre**, **Age rating** (aim All Ages / 9+).
- Permissions → Public.
- Press **Publish to Roblox**.

## Post-launch Watch
- Analytics: `soft_gate_blocked`, `purchase_result`.
- Performance Overlay: FPS ≥ 50 on mid-tier mobile; RTT stable.
- Balance Export: play a run, `/exportbal`, save JSON to tune Tuning.Profiles.
- RemoteWatch: check Output for spam warnings (only during soft-launch).

## Rollback (if something goes sideways)
- Revert to previous commit/PR in Git; re-run `rojo serve`.
- In Roblox: toggle game **Private**; or turn `softLaunch=true` again.
- Disable IAP by setting `enableIAP=false` in FeatureFlags (hot via Admin Panel).

That’s it—ship it, then iterate!
