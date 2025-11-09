# Playtest Checklist
- Local build: `wally install` → `rojo serve` → join in Studio.
- Admin tools only in Studio or whitelisted accounts.
- Verify:
  - FPS cap stable on mobile
  - Nav volumes keep enemies off spawn
  - Spawn fairness (time-to-contact ≥ N seconds)
  - Monetization UI hidden for <13 accounts
  - No errors for 10 minutes of play
## Commands / Toggles
- `/audit` and `/shipcheck` surface: StreamingEnabled, remotes count, memory/fps probes.
- Keep `/release` guarded behind Studio or whitelist.
## Telemetry (minimum)
- `session_start/session_end`
- `purchase_attempt/purchase_success/purchase_failed`
- `soft_gate_blocked` (age/region)
- p95 heartbeat, server player count
