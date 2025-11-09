# Policy & Age Gating
- Server evaluates PolicyService per-player and caches for 5 minutes.
- Clients call `PolicyRemotes.GetPolicyFlags` to hide purchase UI (soft guard).
- Server `ProcessReceipt` denies grants when policy forbids monetization.
- Dev command `/policycheck` logs the current player’s policy state.
