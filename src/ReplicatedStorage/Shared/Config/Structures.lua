-- Buildable structure definitions. Placement, costs, damage, and rewards must be validated server-side.

local Structures = {
	WoodWall = {
		id = "wood_wall",
		displayName = "Wood Wall",
		description = "Cheap barrier that slows basic enemies and buys the team time.",
		costs = { wood = 6 },
		stats = {
			maxHealth = 250,
			blocksMovement = true,
		},
		tuning = {
			buildSeconds = 2.0,
			repairCostMultiplier = 0.5,
		},
	},

	ReinforcedWall = {
		id = "reinforced_wall",
		displayName = "Reinforced Wall",
		description = "Durable wall for late-night pressure and boss waves.",
		costs = { wood = 8, scrap = 5 },
		stats = {
			maxHealth = 550,
			blocksMovement = true,
		},
		tuning = {
			buildSeconds = 3.25,
			repairCostMultiplier = 0.55,
		},
	},

	Door = {
		id = "door",
		displayName = "Door",
		description = "Team passage point that can be opened by players and damaged by enemies.",
		costs = { wood = 5, scrap = 2 },
		stats = {
			maxHealth = 220,
			blocksMovement = true,
		},
		tuning = {
			buildSeconds = 2.25,
			interactionRange = 10,
		},
	},

	SpikeTrap = {
		id = "spike_trap",
		displayName = "Spike Trap",
		description = "Ground trap that damages enemies crossing its trigger area.",
		costs = { wood = 4, scrap = 4 },
		stats = {
			maxHealth = 160,
			damage = 35,
		},
		tuning = {
			buildSeconds = 2.5,
			triggerCooldown = 1.25,
		},
	},

	SlowTotem = {
		id = "slow_totem",
		displayName = "Slow Totem",
		description = "Utility structure that slows enemies in a small aura.",
		costs = { wood = 5, shards = 3 },
		stats = {
			maxHealth = 140,
			radius = 18,
		},
		tuning = {
			buildSeconds = 3.0,
			slowMultiplier = 0.75,
		},
	},

	Lantern = {
		id = "lantern",
		displayName = "Lantern",
		description = "Light source that improves visibility and counters darkness pressure.",
		costs = { wood = 3, fuel = 1 },
		stats = {
			maxHealth = 100,
			lightRadius = 24,
		},
		tuning = {
			buildSeconds = 1.75,
			fuelMinutes = 6,
		},
	},

	Watchtower = {
		id = "watchtower",
		displayName = "Watchtower",
		description = "Elevated platform for spotting and defending against waves.",
		costs = { wood = 12, scrap = 3 },
		stats = {
			maxHealth = 380,
			sightBonus = 1.35,
		},
		tuning = {
			buildSeconds = 4.5,
			playerCapacity = 2,
		},
	},

	Generator = {
		id = "generator",
		displayName = "Generator",
		description = "Powered support structure that boosts nearby camp systems when fueled.",
		costs = { scrap = 10, fuel = 3 },
		stats = {
			maxHealth = 300,
			radius = 28,
		},
		tuning = {
			buildSeconds = 5.0,
			fuelDrainPerMinute = 1,
		},
	},
}

return Structures
