# Survive 99: Evolved — Complete Game Specification

## 1. Purpose of This Specification

This document is the authoritative product, design, technical, and implementation specification for **Survive 99: Evolved**, a team-based Roblox survival game inspired by 99-night survival experiences. A GPT coding agent should be able to use this document as the primary source of truth to complete the full game from the current repository state.

The project is a mobile-first Roblox co-op survival/base-defense game. Players work together to protect a central Beacon across a 99-night campaign by gathering resources, building defenses, fighting enemies, reviving teammates, completing map events, defeating bosses, and unlocking persistent cosmetics and progression.

This specification defines:

- Core gameplay loops.
- Day/night structure.
- Team survival mechanics.
- Resource and inventory systems.
- Building, traps, structures, and repair rules.
- Beacon mechanics and upgrades.
- Combat, weapons, roles, enemies, bosses, and wave scaling.
- Omens, events, map systems, rewards, economy, progression, monetization, and live operations.
- Required server authority, anti-exploit validation, networking contracts, persistence, analytics, testing, and performance requirements.
- An implementation roadmap suitable for autonomous coding agents.

When code and this document conflict, update the code to match this document unless a platform restriction, Roblox policy requirement, or security concern requires a safer alternative.

---

## 2. Existing Project Context

The repository is a Roblox/Rojo Luau project with existing client, server, shared, service, net, ECS-style component, test, and live-ops scaffolding. Implementation should preserve and extend the existing architecture wherever practical.

Existing concepts in the repository include, but are not limited to:

- Server services for survival, combat, AI, spawning, Beacon, building, data, store, cosmetics, tutorial, policy, atmosphere, live config, soft launch, rescue, and analytics.
- Shared configuration for tuning, economy, store, cosmetics, feature flags, atmosphere, localization, wave planning, and constants.
- Client scripts for HUD, tutorial, mobile controls, radial build menu, audio, ambience, VFX, cosmetics, purchase guards, patch notes, credits, and performance overlay.
- ECS-style components and systems for enemy AI, pathfinding, health/death, traps, boss abilities, structure damage, cleanup, Beacon aura, squad brain, movement, threat, attacks, loot, combat, revives, wave director, and autosave.
- Tests for rate limiting, receipts, and AI stress.

The final game should consolidate duplicate legacy/starter folders when necessary, but this SPEC does not require immediate structural deletion. Prioritize functional correctness, security, gameplay completeness, and maintainability.

---

## 3. Product Vision

### 3.1 High-Level Pitch

**Survive 99: Evolved** is a cooperative survival game where teams defend a mystical Beacon against escalating nightly monster attacks for 99 nights. Days are for gathering, crafting, building, repairing, exploring, and rescuing survivors. Nights are tense defensive battles where the team must hold the line, revive fallen friends, counter special enemies, and preserve the Beacon.

### 3.2 Core Fantasy

Players are stranded survivors in a cursed wilderness. The Beacon is their only source of safety. Every day gives a brief moment of hope and preparation. Every night brings darkness, monsters, omens, and pressure. By working together, players transform a fragile camp into a fortified stronghold and eventually power the Beacon enough to escape.

### 3.3 Experience Pillars

1. **Team Survival** — Players must cooperate. Building, gathering, fighting, repairing, scouting, and reviving all matter.
2. **Day/Night Tension** — Safe-ish days and dangerous nights produce a clear emotional rhythm.
3. **Base Defense Creativity** — Players build defenses around the Beacon and adapt their base to enemy threats.
4. **Mobile-First Accessibility** — Every action must work on phones with readable UI, large buttons, and forgiving inputs.
5. **Escalating Replayability** — Enemies, omens, bosses, resources, map events, and roles create varied runs.
6. **Fair Progression** — Persistent rewards should focus on cosmetics, titles, convenience, and prestige, not pay-to-win power.

---

## 4. Target Audience and Platform

### 4.1 Platform Priority

1. Roblox mobile.
2. Roblox desktop.
3. Roblox console/gamepad.

### 4.2 Audience

Primary audience:

- Roblox players who enjoy co-op survival, base defense, wave defense, horror-lite games, and short-session multiplayer.

Age/readability assumptions:

- Broad Roblox audience.
- Avoid graphic gore.
- Use stylized scares, suspense, and readable combat.
- UI text should be short and simple enough for younger players.

### 4.3 Session Length Targets

Supported session lengths:

- 5 minutes: first night/tutorial or quick drop-in.
- 15 minutes: several nights.
- 30–45 minutes: meaningful run progression.
- Long-form: dedicated groups pushing deep-night milestones.

The full 99-night campaign may span a long session or be adapted into checkpoint/private-server formats if Roblox session constraints require it.

---

## 5. Game Modes

### 5.1 Standard 99-Night Survival

Default mode.

Rules:

- Team attempts to survive Nights 1–99.
- Normal rewards.
- Revives enabled.
- Paid revive products may be available only if policy allows and should be limited.
- Leaderboard eligibility optional.

### 5.2 Quick Survival

Short mobile-friendly mode.

Rules:

- Survive 10 nights.
- Faster resource gain.
- Shorter days and nights.
- Boss on Night 10.
- Rewards scaled down but satisfying.

### 5.3 Hardcore

Advanced prestige mode.

Rules:

- No paid revives.
- Stronger waves.
- Less forgiving downed timers.
- Better cosmetic/prestige rewards.
- Leaderboard eligible.

### 5.4 Private Sandbox

Private-server/dev mode.

Rules:

- Admin controls enabled for owners/developers.
- Spawn enemies, set night, grant resources, test builds.
- No leaderboard rewards.
- Optional reduced persistent rewards.

---

## 6. Core Game Loop

### 6.1 Macro Loop

A complete run is built around escalating nights:

1. Spawn at Beacon.
2. Learn or select role.
3. Gather resources during day.
4. Deposit resources into team storage.
5. Build, repair, craft, and upgrade.
6. Vote to start night or wait for dusk timer.
7. Defend Beacon through enemy waves.
8. Revive teammates and repair structures under pressure.
9. Survive until dawn.
10. Receive rewards and progression.
11. Repeat until defeat or Night 99 victory.

### 6.2 Minute-to-Minute Day Loop

During day, players should constantly make meaningful choices:

- Stay near Beacon and build.
- Scout for high-value resources.
- Escort/rescue an NPC.
- Complete optional event.
- Repair damaged defenses.
- Craft weapons/tools/consumables.
- Upgrade Beacon.
- Prepare for known omen/boss warning.

### 6.3 Minute-to-Minute Night Loop

During night, players react to threats:

- Fight enemies.
- Prioritize special enemies.
- Repair breached walls.
- Trigger abilities.
- Revive downed teammates.
- Use traps and Beacon powers.
- Reposition to threatened sides.
- Manage boss mechanics.

### 6.4 Emotional Loop

The ideal repeating emotional beats:

1. **Relief** — Dawn arrives.
2. **Urgency** — Day timer starts.
3. **Planning** — Team chooses tasks.
4. **Risk** — Players venture out.
5. **Warning** — Dusk begins.
6. **Panic** — Enemies breach defenses.
7. **Clutch** — Revives, repairs, and abilities save the run.
8. **Reward** — Night clear rewards appear.

---

## 7. Match Structure and Player Scaling

### 7.1 Player Count

Recommended values:

| Setting | Value |
|---|---:|
| Minimum players | 1 |
| Recommended team | 4 |
| Maximum players | 8 |

The game must be playable solo but most fun with 3–6 players.

### 7.2 Difficulty Scaling

Difficulty must scale with active, non-spectating players.

Suggested formulas:

```lua
local effectivePlayers = math.max(1, activePlayers)
local waveBudget = baseBudget * (1 + 0.55 * (effectivePlayers - 1))
local resourceSpawnRate = baseRate * (1 + 0.35 * (effectivePlayers - 1))
local beaconMaxHp = baseBeaconHp * (1 + 0.20 * (effectivePlayers - 1))
```

Scaling rules:

- Do not scale linearly with player count; Roblox teams are often disorganized.
- Resource availability should increase with team size.
- Boss health should scale less aggressively than wave enemy count.
- Revive pressure naturally increases with player count; do not overpunish.

### 7.3 Join In Progress

If a player joins during day:

- Spawn near Beacon.
- Load persistent profile.
- Give starter kit.
- Show current objective.

If a player joins during night:

- Spawn within Beacon safe radius.
- Apply 5 seconds of spawn protection.
- Give reduced starter kit.
- Do not spawn outside the base.

### 7.4 Player Leaving

When a player leaves:

- Save profile.
- Remove personal carried resources unless safely deposited.
- Team-owned structures remain.
- Active difficulty updates at next phase boundary.
- If all players leave, server can cleanly end the run.

---

## 8. Phase System

### 8.1 Phase List

The game has these core phases:

1. `Lobby`
2. `Day`
3. `Dusk`
4. `Night`
5. `DawnReward`
6. `Defeat`
7. `Victory`

### 8.2 Lobby Phase

Purpose:

- Load players.
- Initialize profiles.
- Select roles.
- Spawn Beacon and core map.
- Show tutorial prompts.

Duration:

- 10–20 seconds, or until minimum requirements are met.

### 8.3 Day Phase

Purpose:

- Prepare and explore.

Default duration by night:

| Night Range | Day Duration |
|---|---:|
| 1–5 | 150 seconds |
| 6–20 | 120 seconds |
| 21–50 | 100 seconds |
| 51–80 | 80 seconds |
| 81–99 | 60 seconds |

Day ends when:

- Timer expires.
- Majority votes to start night.
- Admin command starts night in dev/private mode.

### 8.4 Dusk Phase

Purpose:

- Warn players and transition atmosphere.

Duration:

- 10 seconds.

Effects:

- Sky darkens.
- Beacon pulses.
- Audio sting plays.
- HUD shows countdown.
- Distant enemy spawn cues begin.

### 8.5 Night Phase

Purpose:

- Combat and defense.

Night duration by range:

| Night Range | Typical Duration |
|---|---:|
| 1–5 | 120 seconds |
| 6–20 | 150 seconds |
| 21–50 | 180 seconds |
| 51–80 | 210 seconds |
| 81–99 | 240 seconds |

Night ends when:

- Wave plan complete and enemies defeated.
- Night timer expires and director retreats remaining non-boss enemies.
- Boss is defeated or scripted boss objective completes.
- Beacon destroyed, triggering defeat.

### 8.6 Dawn Reward Phase

Purpose:

- Cleanup, recovery, rewards.

Duration:

- 10–20 seconds.

Effects:

- Remove or retreat surviving enemies.
- Restore limited player health.
- Respawn eliminated players at Beacon if rules allow.
- Show rewards.
- Save important progression.

---

## 9. Win, Defeat, and Recovery Conditions

### 9.1 Victory

Primary victory:

- Survive through Night 99 and complete the final Beacon Ascension event.

Night 99 final event requirements:

1. Beacon enters overload mode.
2. Team must defend against elite waves.
3. Boss channels on Beacon periodically.
4. Players must fuel 3–5 Beacon pylons.
5. Team must interrupt final boss channel.
6. Extraction portal opens.
7. At least one living player activates extraction.

Victory rewards:

- Large Shard payout.
- Victory badge/title.
- Role XP bonus.
- Cosmetic unlock.
- Highest-night profile update.

### 9.2 Defeat

Defeat occurs if:

- Beacon HP reaches 0.
- All active players are downed/eliminated for more than 15 seconds.
- A final event objective fails.
- Hardcore-specific failure condition triggers.

Defeat flow:

1. Stop new enemy spawns.
2. Play Beacon collapse VFX/SFX.
3. Freeze or slow combat.
4. Show survived nights and team stats.
5. Grant partial rewards.
6. Offer restart/return options.

### 9.3 Partial Rewards

Players should receive partial rewards even after defeat.

Suggested formula:

```lua
local baseShards = math.floor(nightsSurvived / 2)
local bonusShards = bossesDefeated * 5 + rescuedSurvivors * 3 + omenNightsSurvived
local finalShards = math.clamp(baseShards + bonusShards, 0, maxSessionReward)
```

---

## 10. Player Roles

Roles support teamwork. They must be understandable, balanced, and non-pay-to-win.

### 10.1 Shared Role Rules

- Players select role at start or use default Survivor.
- Role can be changed in lobby or at role station during day with cooldown.
- Role effects apply server-side.
- Persistent role levels unlock mostly cosmetics.
- No role should be mandatory for early survival.

### 10.2 Survivor

Beginner all-rounder.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 100 |
| Walk Speed | 16 |
| Gather Rate | 1.0x |
| Repair Rate | 1.0x |
| Damage | 1.0x |

Ability: **Adrenaline Rush**

- Speed +30%.
- Duration: 6 seconds.
- Cooldown: 60 seconds.

### 10.3 Builder

Defense and repair specialist.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 110 |
| Walk Speed | 15 |
| Build Cost | 0.85x |
| Repair Rate | 1.35x |
| Damage | 0.9x |

Ability: **Instant Brace**

- Nearby structures gain temporary armor.
- Radius: 20 studs.
- Duration: 12 seconds.
- Cooldown: 90 seconds.

Passive:

- Builder-placed walls have +20% max HP.

### 10.4 Scout

Exploration and gathering specialist.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 85 |
| Walk Speed | 19 |
| Gather Rate | 1.25x |
| Carry Capacity | 1.25x |
| Damage | 0.85x |

Ability: **Flare Ping**

- Reveals resources, enemies, and downed players.
- Radius: 120 studs.
- Duration: 8 seconds.
- Cooldown: 70 seconds.

Passive:

- Sprint stamina cost reduced by 20%.

### 10.5 Medic

Revive and healing specialist.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 95 |
| Walk Speed | 16 |
| Revive Speed | 1.75x |
| Damage | 0.85x |

Ability: **Healing Pulse**

- Heals nearby players.
- Radius: 25 studs.
- Heal: 25 HP.
- Cooldown: 80 seconds.

Passive:

- Revived players return with 50% HP instead of 30%.

### 10.6 Hunter

Combat specialist.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 100 |
| Walk Speed | 16 |
| Damage | 1.25x |
| Gather Rate | 0.9x |

Ability: **Marked Prey**

- Marks strongest nearby enemy.
- Team deals +20% damage to marked enemy.
- Duration: 10 seconds.
- Cooldown: 75 seconds.

Passive:

- Critical hit chance against special enemies.

### 10.7 Engineer

Trap and gadget specialist.

Stats:

| Stat | Value |
|---|---:|
| Max Health | 95 |
| Walk Speed | 15 |
| Trap Cost | 0.8x |
| Repair Rate | 1.15x |

Ability: **Overclock Trap**

- Resets cooldown of nearby traps.
- Boosts trap damage/slow.
- Radius: 20 studs.
- Cooldown: 100 seconds.

Passive:

- Engineer traps have +15% durability.

---

## 11. Player Survival Mechanics

### 11.1 Runtime Player State

```lua
local PlayerState = {
    userId = 0,
    role = "Survivor",
    health = 100,
    maxHealth = 100,
    stamina = 100,
    maxStamina = 100,
    downed = false,
    eliminated = false,
    inventory = {},
    abilityCooldowns = {},
    reviveTokens = 0,
    cosmetics = {},
}
```

### 11.2 Health

Players lose health from:

- Enemy attacks.
- Boss abilities.
- Environmental hazards.
- Omen effects.
- Poison/fire/shock status effects.

At 0 HP, players become downed unless a mode-specific rule eliminates them instantly.

### 11.3 Downed State

Downed players:

- Crawl at 30% speed.
- Cannot attack, build, repair, or gather.
- Can ping for help.
- Have an icon visible to teammates.
- Have a bleed-out timer.

Default downed timer:

- 45 seconds standard.
- 30 seconds hardcore.
- +10 seconds if within upgraded Beacon aura.

### 11.4 Revive

Revive requirements:

- Reviver alive.
- Target downed.
- Reviver within 8 studs.
- Hold interact for 4 seconds by default.
- Taking damage slows or interrupts revive based on tuning.

After revive:

- Target returns with 30% HP by default.
- Medic passive returns target with 50% HP.
- Target receives 3 seconds invulnerability.

### 11.5 Elimination

If bleed-out expires:

- Player becomes eliminated/spectator.
- Player returns at dawn in standard mode.
- Paid revive token may be used only if policy allows and mode permits.
- Hardcore may require rescue event or next major checkpoint.

### 11.6 Stamina

Stamina is used for:

- Sprinting.
- Heavy attacks.
- Dodge/roll if implemented.
- Carrying heavy fuel cells or event objects.

Base values:

| Stat | Value |
|---|---:|
| Max Stamina | 100 |
| Sprint Cost | 18/sec |
| Regen | 12/sec |
| Regen Delay | 1 sec |

---

## 12. Resources, Gathering, and Inventory

### 12.1 Resource Types

| Resource | Purpose | Sources |
|---|---|---|
| Wood | Walls, doors, basic repairs | Trees, crates, salvage |
| Scrap | Traps, metal builds, weapons | Wreckage, vehicles, toolboxes |
| Food | Healing, stamina items | Bushes, caches, fishing, rescue |
| Fuel | Beacon boosts, lanterns, generators, final event | Fuel cans, camps, drops |
| Shards | Persistent cosmetic/meta currency | Night clears, bosses, events |
| Essence | Beacon upgrades, omen counters, late crafting | Omens, elites, bosses |

### 12.2 Resource Nodes

```lua
local ResourceNode = {
    id = "node_001",
    type = "Wood",
    amount = 30,
    gatherDuration = 2.0,
    respawnTime = 180,
    requiredTool = nil,
    rarity = "Common",
}
```

Node rules:

- Server tracks remaining amount.
- Client can show local progress UI.
- Server validates distance and tool.
- Nodes can respawn during long sessions.
- Rare resources should spawn farther from Beacon.

### 12.3 Gathering UX

Mobile:

- Contextual interact button.
- Hold to gather.
- Optional auto-target nearest resource in front of player.

Desktop:

- Press/hold interact key.
- Tool swings optional.

### 12.4 Personal Carry Capacity

| Resource | Base Carry |
|---|---:|
| Wood | 30 |
| Scrap | 20 |
| Food | 10 |
| Fuel | 5 |
| Essence | 3 |

Scout receives +25% capacity.

### 12.5 Team Storage

Resources become team-usable after deposit at:

- Beacon.
- Storage crate.
- Builder station.

Team storage powers:

- Building.
- Repairs.
- Crafting.
- Beacon upgrades.

### 12.6 Dropped Resources

When a player is downed or eliminated:

- A percentage of carried resources may drop.
- Dropped resources despawn after a timer.
- Teammates can recover them.

Suggested values:

- Downed: drop 25% only in hardcore or high difficulty.
- Eliminated: drop 50% carried resources.
- Standard mode can be forgiving and keep resources until death only.

---

## 13. Building and Base Defense

### 13.1 Building Goals

Building should be fast, readable, cooperative, and mobile-friendly. Players should create chokepoints and layered defenses without exploiting pathfinding or trapping teammates.

### 13.2 Placement Validation

All placement must be validated server-side.

Rules:

- Player is alive.
- Structure type exists in config.
- Player is within placement range.
- Placement is near Beacon or valid outpost.
- Placement is snapped to grid.
- Placement does not overlap invalid geometry.
- Placement does not exceed per-player or team caps.
- Placement does not fully block required navigation in exploitative ways.
- Team has required resources.
- Rate limiter allows action.

### 13.3 Build UX

Mobile:

- Tap Build button.
- Choose category from radial menu.
- Drag/aim ghost preview.
- Rotate button.
- Confirm button.
- Cancel button.

Feedback:

- Green preview = valid.
- Red preview = invalid.
- Invalid reason shown briefly.
- Cost and team resources visible.

### 13.4 Structure Categories

Defensive:

- Wood Wall.
- Reinforced Wall.
- Door.
- Barricade.
- Watchtower.

Traps:

- Spike Trap.
- Slow Totem.
- Flame Trap.
- Shock Coil.
- Snare Wire.

Utility:

- Lantern.
- Storage Crate.
- Repair Station.
- Alarm Bell.
- Generator.

Beacon:

- Beacon Shield Node.
- Beacon Pulse Node.
- Beacon Fuel Injector.
- Beacon Decoy.

### 13.5 Structure Specs

| Structure | Cost | HP | Purpose |
|---|---|---:|---|
| Wood Wall | 10 Wood | 180 | Cheap basic defense |
| Reinforced Wall | 10 Wood, 8 Scrap | 380 | Durable defense |
| Door | 15 Wood, 4 Scrap | 220 | Player passage |
| Barricade | 8 Wood | 100 | Quick temporary blocker |
| Watchtower | 25 Wood, 10 Scrap | 300 | Elevated ranged position |
| Spike Trap | 8 Wood, 4 Scrap | 120 | Damage enemies crossing |
| Slow Totem | 10 Wood, 8 Essence | 120 | Area slow |
| Flame Trap | 6 Scrap, 2 Fuel | 100 | Fire AoE damage |
| Shock Coil | 12 Scrap, 3 Essence | 140 | Stun/shock special enemies |
| Snare Wire | 6 Wood, 3 Scrap | 80 | Root first enemy group |
| Lantern | 5 Wood, 2 Fuel | 80 | Light, anti-shadow |
| Storage Crate | 20 Wood | 160 | Deposit point |
| Repair Station | 15 Wood, 10 Scrap | 180 | Improves nearby repair |
| Alarm Bell | 12 Scrap | 100 | Warning/ping system |
| Generator | 15 Scrap, 5 Fuel | 180 | Powers advanced defenses |

### 13.6 Trap Behavior

Spike Trap:

- Deals 35 physical damage.
- Cooldown: 2 seconds.
- Durability: 20 triggers.

Slow Totem:

- Radius: 20 studs.
- Slow: 35%.
- Does not stack fully with itself.

Flame Trap:

- Applies fire DoT.
- Weaker during Storm omen.
- Strong against Swarmlings.

Shock Coil:

- Stuns or interrupts Sappers/Bruisers.
- Requires Generator or Beacon power.

Snare Wire:

- One-time or limited-use root.
- Good for stopping Sappers.

### 13.7 Repairs

Repair requirements:

- Player alive.
- Structure damaged.
- Player in range.
- Required resource available.

Repair formula:

```lua
local repairPerSecond = baseRepair * roleRepairMultiplier * stationMultiplier
local resourceCost = math.ceil(repairAmount / repairEfficiency)
```

Night repair should be slightly less efficient unless role/station bonuses apply.

---

## 14. Beacon System

### 14.1 Beacon Role

The Beacon is the central objective, safe anchor, team resource deposit, upgrade station, and final extraction device.

### 14.2 Beacon State

```lua
local BeaconState = {
    hp = 1000,
    maxHp = 1000,
    shield = 0,
    maxShield = 0,
    fuel = 0,
    level = 1,
    auraRadius = 60,
    activeBuffs = {},
}
```

### 14.3 Beacon HP Scaling

| Players | Beacon HP |
|---:|---:|
| 1 | 800 |
| 2 | 1000 |
| 4 | 1400 |
| 6 | 1700 |
| 8 | 2000 |

### 14.4 Beacon Damage Feedback

When damaged:

- HUD flashes Beacon HP.
- Alarm sound plays.
- Beacon emits red pulse.
- Directional indicator points to threat.
- Chat/system message warns at key thresholds.

Thresholds:

- 75%: minor warning.
- 50%: urgent warning.
- 25%: critical alarm.
- 0%: defeat sequence.

### 14.5 Beacon Upgrades

Level 1 — Base Beacon:

- Spawn point.
- Deposit point.
- Team storage.

Level 2 — Beacon Shield:

- Cost: 50 Wood, 25 Scrap, 5 Fuel.
- Adds regenerating shield.

Level 3 — Healing Aura:

- Cost: 40 Food, 10 Essence.
- Slowly heals nearby players during day.
- Reduced healing at night.

Level 4 — Pulse Blast:

- Cost: 30 Scrap, 15 Essence.
- Team-triggered AoE knockback/damage.
- Cooldown: 180 seconds.

Level 5 — Final Catalyst:

- Required for Night 99 extraction.
- Cost: high Fuel, Essence, and boss trophies.

### 14.6 Beacon Fuel Uses

Fuel can be spent on:

- Temporary shield burst.
- Beacon pulse.
- Lantern network refill.
- Generator network.
- Final event pylons.

Fuel must be rare enough to create decisions but not so rare that final progression stalls.

---

## 15. Combat System

### 15.1 Combat Principles

Combat should be:

- Server-authoritative.
- Responsive with client-side VFX.
- Forgiving for mobile aim.
- Readable in groups.
- Balanced around teamwork and defenses.

### 15.2 Weapon Types

| Weapon | Damage | Role |
|---|---:|---|
| Stick/Bat | 20 | Starter melee |
| Axe | 28 | Gather/combat hybrid |
| Spear | 24 | Longer melee, knockback |
| Bow/Slingshot | 18 | Starter ranged |
| Scrap Blaster | 35 | Mid-game ranged |
| Beacon Rifle | 45 | Late-game energy weapon |

### 15.3 Damage Types

- Physical.
- Fire.
- Shock.
- Beacon.
- Poison.
- Explosive.

Weakness examples:

| Enemy | Weakness | Resistance |
|---|---|---|
| Swarmling | Fire | None |
| Bruiser | Shock | Physical |
| Screecher | Beacon | Poison |
| Sapper | Physical | Fire |
| Stalker | Light/Beacon | Physical while hidden |
| Miniboss | Beacon | Minor types |

### 15.4 Attack Validation

Server validates:

- Player alive.
- Weapon equipped.
- Cooldown ready.
- Target range.
- Target exists and is damageable.
- Direction/line-of-sight for ranged attacks.
- Damage amount from server config only.

### 15.5 Threat System

Enemies choose targets based on threat:

```lua
local threat = damageDealt * 1.0
    + healingDone * 0.6
    + repairDone * 0.4
    + beaconProximityBonus
    + carriedFuelBonus
    + roleModifier
```

Threat decays over time. Special enemies may override threat with unique target preferences.

---

## 16. Enemy System

### 16.1 Enemy Design Rules

Every enemy must have:

- Distinct silhouette.
- Distinct audio cue.
- Clear combat role.
- Counterplay.
- Spawn budget cost.
- Scaling stats.
- Targeting behavior.

### 16.2 Enemy Data Shape

```lua
local EnemyType = {
    kind = "Swarmling",
    hp = 35,
    speed = 18,
    damage = 8,
    attackRange = 5,
    attackCooldown = 1.1,
    beaconDamageMultiplier = 1.0,
    structureDamageMultiplier = 1.0,
    playerDamageMultiplier = 1.0,
    spawnCost = 4,
    abilities = {},
}
```

### 16.3 Core Enemies

#### Swarmling

- HP: 35.
- Speed: fast.
- Damage: low.
- Cost: 4.
- Role: swarm pressure.
- Counter: traps, AoE, fire.

#### Forager

- HP: 70.
- Speed: medium.
- Damage: medium.
- Cost: 6.
- Role: standard filler.
- Counter: walls, kiting, focus fire.

#### Screecher

- HP: 80.
- Speed: medium.
- Damage: low direct.
- Cost: 10.
- Role: ranged/support disruption.
- Abilities: slow screech, rally nearby enemies.
- Counter: ranged weapons, Hunter mark, Beacon light.

#### Bruiser

- HP: 300.
- Speed: slow.
- Damage: high vs structures.
- Cost: 14.
- Role: wall breaker.
- Abilities: slam, knockback.
- Counter: shock, focus fire, slow totems.

#### Sapper

- HP: 110.
- Speed: medium-fast.
- Damage: explosive.
- Cost: 16.
- Role: defense saboteur.
- Abilities: plant bomb, disable traps, self-destruct.
- Counter: snare, ranged focus, Engineer utility.

#### Stalker

- HP: 90.
- Speed: fast.
- Damage: medium-high.
- Cost: 12.
- Role: punishes isolated players.
- Abilities: semi-invisible outside light.
- Counter: Lanterns, Scout flare, buddy system.

#### Spitter

- HP: 100.
- Speed: medium.
- Damage: poison/acid.
- Cost: 12.
- Role: area denial.
- Abilities: poison puddle, acid projectile.
- Counter: movement, ranged attacks, healing.

#### Warden

- HP: 450.
- Speed: slow.
- Damage: medium.
- Cost: 35.
- Role: elite commander.
- Abilities: enemy armor aura, rally roar, summon pack.
- Counter: burst damage, isolate from pack.

---

## 17. Boss System

### 17.1 Boss Schedule

Recommended:

- Mini-boss every 5 nights.
- Major boss every 10 nights.
- Final boss/event on Night 99.

Boss frequency can be reduced in Quick Survival or early onboarding.

### 17.2 Boss Requirements

Each boss requires:

- Intro warning.
- Distinct music.
- Large health bar.
- Multiple attack patterns.
- Telegraphs.
- Counterplay.
- Reward table.
- Scaling by player count/night.

### 17.3 Hollow Brute

Appears:

- Early boss, Night 5 or 10.

Abilities:

- Ground slam.
- Charge.
- Wall crush.

Counterplay:

- Dodge charge.
- Attack after slam recovery.
- Use slow/shock traps.

Rewards:

- Shards.
- Essence.
- Brute Trophy.

### 17.4 Lantern Eater

Appears:

- Mid-game, Night 20+.

Abilities:

- Extinguishes lanterns.
- Summons Stalkers.
- Darkness field.
- Shadow teleport.

Counterplay:

- Refuel lanterns.
- Scout flare reveals boss.
- Beacon pulse interrupts teleport.

### 17.5 Storm Maw

Appears:

- Storm-themed major night.

Abilities:

- Lightning strikes.
- Pull vortex.
- Chain lightning.
- Trap overcharge malfunction.

Counterplay:

- Spread out.
- Build grounding rods or powered counters.
- Time repairs between strikes.

### 17.6 Final Entity

Appears:

- Night 99.

Phases:

1. Siege Phase — Elite waves attack.
2. Beacon Drain Phase — Boss channels into Beacon; players interrupt crystals.
3. Hunt Phase — Boss targets players directly.
4. Ascension Phase — Fuel pylons and defend extraction portal.

Victory condition:

- Complete Beacon Ascension and activate extraction.

---

## 18. Wave Director

### 18.1 Inputs

Wave planning uses:

- Night number.
- Active player count.
- Average role level/progression.
- Beacon HP percentage.
- Structure count and total structure HP.
- Previous night result.
- Current omen.
- Recent deaths/downed count.
- Difficulty mode.
- Live config overrides.

### 18.2 Output

```lua
local WavePlan = {
    night = 1,
    budget = 100,
    duration = 120,
    omen = nil,
    squads = {
        {
            type = "Swarmling",
            count = 8,
            spawnDelay = 0,
            spawnGroupSize = 4,
            targetPreference = "Beacon",
        },
    },
    boss = nil,
    modifiers = {},
}
```

### 18.3 Difficulty Curve

| Night Range | Design Goal |
|---|---|
| 1–5 | Teach loop, low pressure |
| 6–20 | Introduce specials and first bosses |
| 21–50 | Mix enemy roles and omens |
| 51–80 | High-pressure endurance |
| 81–98 | Elite waves and resource scarcity |
| 99 | Final scripted climax |

### 18.4 Anti-Frustration Rules

If team barely survives:

- Reduce next wave budget by 10–20%.
- Spawn more day resources.
- Delay optional elite squad.

If team dominates:

- Add optional bonus objectives.
- Add elite variants.
- Avoid sudden unfair one-shots.

### 18.5 Spawn Rules

Enemies spawn:

- Outside Beacon safe radius.
- At valid spawn points.
- With valid path to Beacon or target.
- Away from direct player camera when possible.
- With warning effects for elites/bosses.

---

## 19. Omen System

### 19.1 Omen Purpose

Omens are nightly modifiers that create variety, force adaptation, and improve replayability.

### 19.2 Omen Chance

| Night Range | Chance |
|---|---:|
| 1–2 | 0% |
| 3–10 | 20% |
| 11–30 | 35% |
| 31+ | 50% |

Boss nights may force or heavily weight specific omens.

### 19.3 Omens

#### Fog

Effects:

- Reduced visibility.
- More Swarmlings/Stalkers.
- Enemy spawn cues quieter.

Counters:

- Lanterns.
- Scout flare.
- Beacon light upgrades.

#### Storm

Effects:

- Lightning hazards.
- Bruisers more common.
- Fire traps weaker.
- Generators unstable.

Counters:

- Spread out.
- Grounding upgrades.
- Shock-resistant structures.

#### Eclipse

Effects:

- Screechers and shadow enemies stronger.
- Beacon aura reduced.
- Night lasts longer.

Counters:

- Beacon fuel burst.
- Lanterns.
- Essence upgrades.

#### Blood Moon

Effects:

- Enemies move faster.
- More elites.
- Better rewards.

Counters:

- Strong defenses.
- Team coordination.
- Ability timing.

#### Frost

Effects:

- Stamina drains faster outside Beacon aura.
- Enemies slower but tougher.
- Repairs slower.

Counters:

- Campfires.
- Stay grouped.
- Warmth structures.

#### Wildfire

Effects:

- Fire hazards appear.
- Fire traps stronger.
- Wood structures vulnerable.

Counters:

- Scrap structures.
- Water barrels or extinguish action.
- Avoid clustered wood builds.

### 19.4 Omen Rewards

Surviving an omen night grants:

- Bonus Shards.
- Essence chance.
- Omen badge progress.
- Cosmetic progress.

---

## 20. Map, Exploration, and Events

### 20.1 Map Zones

Required zones:

- Beacon Clearing.
- Forest.
- Abandoned Camp.
- Junkyard.
- Cave.
- Swamp.
- Ruined Village.
- Watchtower Hill.
- Boss Arena/ritual area.
- Extraction site.

### 20.2 Layout Strategy

Use semi-procedural modular placement:

- Beacon at center.
- Spawn points in rings.
- Resource clusters randomized per run.
- Events spawn from weighted list.
- Rare resources farther from Beacon.

### 20.3 Day Events

#### Rescue Survivor

Steps:

1. Find trapped NPC.
2. Defeat guards or complete hold interaction.
3. Escort or release survivor.
4. Return to Beacon or safe marker.

Rewards:

- Shards.
- Food.
- Temporary helper NPC.
- Team buff.

#### Supply Drop

- Flare marks crate.
- Timed despawn.
- Enemy ambush chance.
- Rewards Fuel/Scrap/tools.

#### Broken Generator

- Repair before night.
- Powers lights in a map region.
- Grants Fuel or disables one omen effect locally.

#### Cursed Shrine

Options:

- Cleanse for safe reward.
- Activate for harder night and better reward.
- Ignore.

#### Lost Backpack

- Simple beginner-friendly loot event.
- Contains resources, lore, or cosmetic progress.

---

## 21. Crafting and Upgrades

### 21.1 Stations

Workbench:

- Tools.
- Basic weapons.
- Basic traps.

Forge:

- Metal structures.
- Advanced weapons.
- Boss trophy upgrades.

Medic Station:

- Bandages.
- Revive kits.
- Stamina food.

Beacon Forge:

- Essence gear.
- Late-game upgrades.
- Final event components.

### 21.2 Crafting Rules

- Recipes are config-driven.
- Server validates station proximity and resources.
- Team resources are consumed only on server success.
- Craft progress may take time for advanced items.

### 21.3 Upgrade Tiers

1. Crude.
2. Reinforced.
3. Advanced.
4. Beacon-Forged.
5. Ascended.

Most run upgrades reset per run. Persistent upgrades should be cosmetic or minor convenience only.

---

## 22. Economy, Rewards, and Progression

### 22.1 Currencies

Shards:

- Persistent soft currency.
- Used for cosmetics, titles, emotes, Beacon skins.

Coins, optional:

- Session currency for temporary purchases.

Essence:

- Run-limited or rare persistent currency.
- Used for Beacon upgrades and anti-omen crafting.

### 22.2 Reward Events

Reward:

- Night clear.
- Omen survival.
- Boss defeat.
- Rescue event.
- Revives.
- Repairs.
- Resource deposits.
- Final victory.

Avoid encouraging selfish stat farming. Team success should provide the majority of rewards.

### 22.3 Suggested Rewards

| Event | Shards |
|---|---:|
| Night clear | 1 |
| Omen night clear | +1 |
| Rescue survivor | 3 |
| Mini-boss | 5 |
| Major boss | 10 |
| Night 99 victory | 50 |

### 22.4 Reward Screen

Show:

- Night survived.
- Team rewards.
- Personal contribution.
- Shards earned.
- Role XP gained.
- Unlock progress.
- Next-night warning or hint.

---

## 23. Persistent Profile

### 23.1 Profile Shape

```lua
local Profile = {
    version = 1,
    shards = 0,
    totalNightsSurvived = 0,
    highestNight = 0,
    wins = 0,
    losses = 0,
    roles = {
        Builder = { xp = 0, level = 1 },
        Scout = { xp = 0, level = 1 },
        Medic = { xp = 0, level = 1 },
        Hunter = { xp = 0, level = 1 },
        Engineer = { xp = 0, level = 1 },
    },
    cosmetics = {
        owned = {},
        equipped = {},
    },
    settings = {},
    tutorial = {},
    achievements = {},
    daily = {},
}
```

### 23.2 Save Triggers

Save:

- Player leave.
- Every 60 seconds with jitter.
- After purchase grant.
- After major achievement.
- At match end.

### 23.3 Migrations

Profiles require a `version` field. Migration functions must be safe, idempotent, and additive.

---

## 24. Cosmetics and Monetization

### 24.1 Monetization Principles

- No pay-to-win.
- No mandatory purchases.
- Respect Roblox policy and age gates.
- Disable purchase UI when policy requires.
- All purchases granted server-side through receipt processing.

### 24.2 Cosmetic Products

Allowed cosmetics:

- Character skins.
- Weapon skins.
- Beacon skins.
- Structure skins.
- Trails.
- Emotes.
- Victory poses.
- Titles.

### 24.3 Game Passes

Acceptable game passes:

- Supporter badge.
- Cosmetic aura.
- Extra cosmetic loadout slots.
- Private server convenience controls.

### 24.4 Dev Products

Use carefully:

- Revive token.
- Shard bundle.
- Cosmetic crate.

Revive token restrictions:

- Limited uses per run.
- Disabled in Hardcore and leaderboard modes.
- Disabled where policy requires.
- Never required to continue receiving normal rewards.

### 24.5 Seasons

Optional season track:

- Free track with cosmetics and Shards.
- Premium track with additional cosmetics only.
- No exclusive gameplay power.

---

## 25. Social and Team Systems

### 25.1 Pings

Ping types:

- Resource.
- Enemy.
- Downed teammate.
- Build here.
- Danger.
- Return to base.
- Need repair.

Mobile:

- Contextual ping button.
- Short cooldown.

### 25.2 Team Votes

Vote on:

- Start night early.
- Spend rare Beacon upgrade.
- Activate cursed shrine.
- Begin final extraction.

Votes should timeout and default to the safer option.

### 25.3 Contribution Recognition

At reward screen, recognize:

- Defender.
- Gatherer.
- Builder.
- Medic.
- Scout.
- MVP.

Do not shame low contributors.

---

## 26. Tutorial and Onboarding

### 26.1 First-Time Tutorial

Required steps:

1. Move to Beacon.
2. Gather Wood.
3. Deposit Wood.
4. Build Wall.
5. Attack enemy.
6. Repair structure.
7. Revive teammate/NPC dummy.
8. Survive first night.

Rules:

- Tutorial is progressive.
- Each step detects completion.
- Prompts are short.
- Returning players can skip.

### 26.2 Dynamic Tips

Examples:

- “Sappers explode near walls. Focus them first.”
- “Lanterns reveal Stalkers.”
- “Builders repair faster.”
- “Fuel can power Beacon shields.”

---

## 27. User Interface

### 27.1 HUD Elements

Required HUD:

- Beacon HP/shield.
- Current phase.
- Night number.
- Timer.
- Omen indicator.
- Player health.
- Stamina.
- Ability button.
- Attack button.
- Interact button.
- Build button.
- Resource counters.
- Downed teammate indicators.

### 27.2 Mobile Layout

- Left side: movement joystick.
- Right side: attack/interact/build.
- Bottom center: ability.
- Top center: Beacon/timer/night.
- Top right: settings/performance optional.

### 27.3 Build UI

Must show:

- Structure icon.
- Cost.
- Team resources.
- Description.
- Cap/limit.
- Invalid placement reason.

### 27.4 Reward UI

Must show:

- Night survived.
- Team rewards.
- Personal contribution.
- Unlock progress.
- Continue/ready prompt.

### 27.5 Downed UI

Must show:

- Bleed-out timer.
- “Teammates can revive you.”
- Ping for help button.
- Nearest teammate distance.

---

## 28. Audio, Visuals, and Accessibility

### 28.1 Visual Style

- Stylized survival horror-lite.
- Readable silhouettes.
- Minimal gore.
- Strong color contrast between safe Beacon energy and hostile enemy energy.

### 28.2 Atmosphere

Day:

- Warm, hopeful, clear.

Dusk:

- Orange/purple warning.

Night:

- Dark blue, fog, glowing eyes.

Beacon:

- Cyan/gold safe energy.

Enemies:

- Red/purple hostile energy.

### 28.3 Audio Requirements

Required sounds:

- Day ambience.
- Night ambience.
- Night start horn.
- Dawn chime.
- Beacon damage alarm.
- Sapper ticking.
- Screecher scream.
- Boss intro sting.
- Omen warning sting.

### 28.4 Accessibility Settings

Include:

- Reduce flashes.
- Lower screen shake.
- Larger UI.
- Captions/subtitles.
- Colorblind-friendly indicators.
- Disable camera bob.
- Lower intensity mode.

---

## 29. Networking and Security

### 29.1 Server Authority

Server owns:

- Health.
- Damage.
- Enemy AI.
- Resources.
- Build placement.
- Rewards.
- Purchases.
- Profile saving.
- Beacon state.

Client owns:

- Input capture.
- Camera.
- Local UI.
- Local VFX/SFX prediction.

### 29.2 Remote Validation

All inbound remotes validate:

- Player identity.
- Player state.
- Payload shape/type.
- Distance/range.
- Cooldown.
- Rate limit.
- Resource availability.
- Target validity.
- Policy gates for monetization.

### 29.3 Remote Contracts

#### RequestAttack

```lua
{
    weaponId = string,
    targetId = string?,
    origin = Vector3?,
    direction = Vector3?,
    timestamp = number,
}
```

#### RequestBuildPlace

```lua
{
    structureType = string,
    cframe = CFrame,
    rotation = number?,
}
```

#### RequestRepair

```lua
{
    structureId = string,
}
```

#### RequestGather

```lua
{
    nodeId = string,
    toolId = string?,
}
```

#### RequestDeposit

```lua
{
    resourceType = string?,
    amount = number?,
}
```

#### RequestRevive

```lua
{
    targetUserId = number,
}
```

#### RequestAbility

```lua
{
    abilityId = string,
    target = any?,
}
```

#### RequestNightStartVote

```lua
{
    vote = boolean,
}
```

#### RequestCraft

```lua
{
    recipeId = string,
    count = number,
}
```

#### RequestPing

```lua
{
    pingType = string,
    position = Vector3,
    targetId = string?,
}
```

### 29.4 Server-to-Client Events

Required events:

- `StatePhaseChanged`.
- `StateBeaconChanged`.
- `StateResourcesChanged`.
- `StatePlayerDowned`.
- `StateWaveUpdate`.
- `StateReward`.
- `ShowOmenWarning`.
- `ShowBossIntro`.
- `ShowErrorToast`.

---

## 30. AI and ECS Requirements

### 30.1 AI States

- Spawn.
- SeekBeacon.
- SeekTarget.
- AttackStructure.
- AttackPlayer.
- UseAbility.
- Flee.
- Stunned.
- Dead.

### 30.2 Components

Recommended components:

- Position.
- Health.
- EnemyType.
- Target.
- AIState.
- Path.
- Attack.
- Threat.
- InstanceRef.
- Boss.
- Trap.
- Buildable.

### 30.3 Pathfinding Rules

- Path to Beacon by default.
- Target high-threat players when appropriate.
- Attack blocking structures.
- Respect nav block/high-cost volumes.
- Recalculate paths on throttled intervals.
- Use squad-level movement for swarms where possible.

### 30.4 AI Performance

- Do not pathfind every enemy every frame.
- Use staggered updates.
- Pool enemy instances.
- Cap active enemies.
- Despawn or retreat irrelevant enemies at dawn.

---

## 31. Performance Budgets

### 31.1 Client Targets

- 60 FPS on modern mobile.
- 30 FPS minimum on lower-end mobile.
- Avoid excessive point lights and particles.
- Use LOD and simple enemy rigs.

### 31.2 Server Targets

Suggested caps:

| System | Cap |
|---|---:|
| Active enemies | 100 |
| Active structures | 120–200 |
| Active traps | 60 |
| Dropped items | 80 |
| Active projectiles | 100 |

### 31.3 Optimization Rules

- Batch expensive work.
- Rate-limit remotes.
- Avoid unbounded loops.
- Avoid creating/destroying many instances per second.
- Use object pools for projectiles/VFX/enemies when useful.

---

## 32. Live Ops, Analytics, and Admin

### 32.1 Feature Flags

Required flags:

- `softLaunch`.
- `enableIAP`.
- `enableAds`.
- `enableSubscriptions`.
- `enableOmens`.
- `enableBosses`.
- `enableSeason`.
- `enableHardcore`.

### 32.2 Analytics Events

Track:

```lua
analytics.track("phase_start", { phase = phase, night = night, players = count })
analytics.track("night_end", { night = night, survived = survived, beaconHp = hp, deaths = deaths })
analytics.track("player_downed", { night = night, cause = cause })
analytics.track("boss_defeated", { boss = bossId, night = night })
analytics.track("build_placed", { type = structureType, night = night })
analytics.track("resource_deposited", { type = resourceType, amount = amount })
analytics.track("purchase_result", { product = productId, result = result })
analytics.track("tutorial_step", { step = step, completed = true })
```

### 32.3 Admin Tools

Admin/dev commands should support:

- Start night.
- End night.
- Set night number.
- Spawn wave.
- Spawn boss.
- Add resources.
- Damage/heal Beacon.
- Toggle omen.
- Grant test rewards.
- Run ship check.

Admin tools must be protected by user ID allowlist or Roblox permissions.

---

## 33. Configuration Files to Add or Expand

A GPT agent should add these config modules if absent:

- `Shared/Config/Roles.lua`.
- `Shared/Config/Enemies.lua`.
- `Shared/Config/Structures.lua`.
- `Shared/Config/Weapons.lua`.
- `Shared/Config/Omens.lua`.
- `Shared/Config/Bosses.lua`.
- `Shared/Config/Resources.lua`.
- `Shared/Config/Achievements.lua`.
- `Shared/Config/Recipes.lua`.

Config modules should be pure data tables when possible. Server code should validate configs at startup.

---

## 34. Implementation Roadmap

### Milestone 1 — Core Loop

Deliver:

- Day/night phase loop.
- Beacon HP and defeat.
- Basic wave spawning.
- Basic combat.
- Basic rewards.

### Milestone 2 — Team Resources and Building

Deliver:

- Resource nodes.
- Personal inventory.
- Team deposit/storage.
- Build costs.
- Wall/trap placement.
- Structure damage and repair.

### Milestone 3 — Player Survival

Deliver:

- Downed state.
- Revives.
- Respawn at dawn.
- Basic role stat modifiers.
- Tutorial steps.

### Milestone 4 — Enemy Variety

Deliver:

- Swarmling.
- Forager.
- Bruiser.
- Screecher.
- Sapper.
- Stalker.
- Wave director improvements.

### Milestone 5 — Omens and Events

Deliver:

- Fog/Storm/Eclipse.
- Omen UI warnings.
- Rescue survivor event.
- Supply drop event.
- Cursed shrine event.

### Milestone 6 — Bosses

Deliver:

- Boss framework.
- Hollow Brute.
- Lantern Eater.
- Storm Maw.
- Boss rewards.

### Milestone 7 — Persistent Progression

Deliver:

- Profile schema.
- Shards.
- Role XP.
- Cosmetics.
- Achievements.
- Reward screen.

### Milestone 8 — Full 99-Night Campaign

Deliver:

- Late-game wave scaling.
- Night 99 final event.
- Victory flow.
- Final rewards.

### Milestone 9 — Release Readiness

Deliver:

- Policy-aware monetization.
- Live config.
- Analytics.
- Performance pass.
- Mobile UI polish.
- QA and tests.

---

## 35. Testing Requirements

### 35.1 Unit Tests

Test:

- Wave budget scaling.
- Enemy config validity.
- Structure config validity.
- Placement validation.
- Resource cost validation.
- Reward formulas.
- Profile migrations.
- Rate limiting.
- Receipt idempotency.

### 35.2 Integration Tests

Test:

- Full day/night cycle.
- Gather/deposit/build flow.
- Enemy damages structure.
- Player down/revive flow.
- Boss spawn/defeat flow.
- Omen modifies wave correctly.
- Purchase receipt grants exactly once.
- Policy gate disables IAP UI.

### 35.3 Load Tests

Test:

- 8 players.
- 100 active enemies.
- 150 structures.
- 60 traps.
- Frequent combat/build/remotes.
- 20+ simulated nights.

### 35.4 Manual QA Checklist

Before release:

- Mobile controls comfortable.
- HUD readable on phone.
- Early waves fair.
- Beacon warning obvious.
- Revive understandable.
- Build placement cannot exploit map.
- Enemies do not spawn inside base.
- Purchases grant once.
- Data saves correctly.
- Leaving/rejoining does not corrupt run.

---

## 36. Acceptance Criteria

### 36.1 MVP Complete

The MVP is complete when:

- Players can join and spawn.
- Beacon exists and can be damaged.
- Day/night loop works.
- At least 5 nights can be played.
- Enemies spawn and attack Beacon/structures.
- Players can attack enemies.
- Players can gather and deposit resources.
- Players can build walls and traps.
- Structures can be damaged and repaired.
- Players can be downed and revived.
- Rewards are granted after night.
- Profile saves Shards and highest night.
- Mobile HUD is usable.
- Server validates combat/build/gather remotes.

### 36.2 Full Game Complete

The full game is complete when:

- 99-night campaign exists.
- Night 99 final event exists.
- At least 6 enemy types exist.
- At least 3 bosses exist.
- At least 5 omens exist.
- At least 5 roles exist.
- At least 10 buildables exist.
- At least 5 map events/resource event types exist.
- Persistent cosmetics exist.
- Tutorial exists.
- Policy-aware monetization exists.
- Live config tunes major systems.
- Performance targets are met with max players.
- Critical server modules have tests.

---

## 37. Non-Goals Until Core Game Is Stable

Do not prioritize these before the core game is fun and stable:

- PvP.
- Trading.
- Player-made markets.
- Complex hunger/thirst simulation.
- Full procedural terrain generation.
- Permanent paid power.
- Large vehicle systems.
- Dozens of weapon variants.
- Deep RPG stat trees.

---

## 38. Definition of Done

A feature is done only when:

- Server logic is authoritative.
- Client UI feedback exists.
- Mobile controls work.
- Edge cases are handled.
- Exploit validation exists.
- Config values are centralized.
- Analytics are emitted where important.
- Errors fail safely.
- Tests or manual QA notes exist.
- Performance impact is acceptable.

---

## 39. Agent Implementation Priority

If a GPT agent is continuing development from this SPEC, implement in this exact order unless blocked:

1. Audit existing systems and remove duplicate/unused starter paths only after confirming live paths.
2. Add central config modules for roles, structures, enemies, resources, weapons, omens, bosses, recipes, and achievements.
3. Implement team resource inventory and deposit flow.
4. Add build costs and server-side resource validation.
5. Expand enemy configs and wave planner.
6. Polish downed/revive flow.
7. Add role selection, role stats, and abilities.
8. Add omen warnings and omen effects.
9. Add boss framework and first boss.
10. Add reward service and reward screen.
11. Extend persistent profile and migrations.
12. Add cosmetics/progression UI.
13. Implement Night 99 final event.
14. Harden remotes, rate limits, policy gates, and receipts.
15. Complete mobile polish, accessibility, tests, analytics, and performance pass.
