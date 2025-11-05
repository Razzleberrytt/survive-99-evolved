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