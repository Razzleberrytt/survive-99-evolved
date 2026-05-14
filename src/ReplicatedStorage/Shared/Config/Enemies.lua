-- Enemy archetype definitions. Runtime spawning and combat outcomes are server-authoritative.

local Enemies = {
	Swarmling = {
		id = "swarmling",
		displayName = "Swarmling",
		description = "Fast, fragile melee enemy that pressures weak points in groups.",
		stats = { health = 35, speed = 15, damage = 8, attackRange = 4 },
		costs = { waveBudget = 1 },
		tuning = { spawnWeight = 1.0, prefersBeacon = false },
	},

	Forager = {
		id = "forager",
		displayName = "Forager",
		description = "Basic scavenger that targets players and exposed structures.",
		stats = { health = 60, speed = 12, damage = 10, attackRange = 4 },
		costs = { waveBudget = 2 },
		tuning = { spawnWeight = 0.9, resourceDropChance = 0.25 },
	},

	Screecher = {
		id = "screecher",
		displayName = "Screecher",
		description = "Support enemy that alerts nearby monsters and disrupts player positioning.",
		stats = { health = 45, speed = 14, damage = 5, attackRange = 18 },
		costs = { waveBudget = 3 },
		tuning = { spawnWeight = 0.45, alertRadius = 35, cooldown = 10 },
	},

	Bruiser = {
		id = "bruiser",
		displayName = "Bruiser",
		description = "Slow heavy enemy that soaks damage and breaks front-line defenses.",
		stats = { health = 220, speed = 8, damage = 24, attackRange = 5 },
		costs = { waveBudget = 7 },
		tuning = { spawnWeight = 0.25, structureDamageMultiplier = 1.4 },
	},

	Sapper = {
		id = "sapper",
		displayName = "Sapper",
		description = "Structure-focused enemy that punishes unguarded walls and traps.",
		stats = { health = 85, speed = 11, damage = 18, attackRange = 5 },
		costs = { waveBudget = 5 },
		tuning = { spawnWeight = 0.35, targetStructuresFirst = true },
	},

	Stalker = {
		id = "stalker",
		displayName = "Stalker",
		description = "Ambusher that threatens isolated players outside Beacon safety.",
		stats = { health = 95, speed = 17, damage = 16, attackRange = 4 },
		costs = { waveBudget = 5 },
		tuning = { spawnWeight = 0.3, prefersIsolatedPlayers = true },
	},

	Spitter = {
		id = "spitter",
		displayName = "Spitter",
		description = "Ranged enemy that forces players to move and repair from safe angles.",
		stats = { health = 75, speed = 10, damage = 14, attackRange = 35 },
		costs = { waveBudget = 6 },
		tuning = { spawnWeight = 0.28, projectileSpeed = 55, cooldown = 3.5 },
	},

	Warden = {
		id = "warden",
		displayName = "Warden",
		description = "Elite commander that anchors late waves and empowers nearby enemies.",
		stats = { health = 420, speed = 9, damage = 28, attackRange = 6 },
		costs = { waveBudget = 15 },
		tuning = { spawnWeight = 0.08, auraRadius = 30, auraDamageMultiplier = 1.15 },
	},
}

return Enemies
