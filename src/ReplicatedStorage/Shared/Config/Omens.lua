-- Omen definitions for run modifiers. Selection and rewards must be controlled by the server.

local Omens = {
	Fog = {
		id = "fog",
		displayName = "Fog",
		description = "Visibility drops, making scouting and lantern placement more important.",
		stats = { visibilityMultiplier = 0.55 },
		costs = {},
		tuning = { baseChance = 0.15, rewardMultiplier = 1.05 },
	},

	Storm = {
		id = "storm",
		displayName = "Storm",
		description = "Heavy weather reduces mobility and stresses powered structures.",
		stats = { movementMultiplier = 0.95, generatorEfficiency = 0.85 },
		costs = {},
		tuning = { baseChance = 0.1, rewardMultiplier = 1.08 },
	},

	Eclipse = {
		id = "eclipse",
		displayName = "Eclipse",
		description = "The night arrives with stronger darkness and more dangerous enemy behavior.",
		stats = { beaconLightMultiplier = 0.85 },
		costs = {},
		tuning = { baseChance = 0.08, rewardMultiplier = 1.12 },
	},

	BloodMoon = {
		id = "blood_moon",
		displayName = "Blood Moon",
		description = "Enemy aggression rises and defeated enemies may split into lesser threats.",
		stats = { enemySpeedMultiplier = 1.15, enemyDamageMultiplier = 1.05 },
		costs = {},
		tuning = { baseChance = 0.06, rewardMultiplier = 1.18, splitChance = 0.12 },
	},

	Frost = {
		id = "frost",
		displayName = "Frost",
		description = "Cold slows repairs and encourages teams to cluster around light and heat.",
		stats = { repairSpeedMultiplier = 0.85, staminaRegenMultiplier = 0.9 },
		costs = {},
		tuning = { baseChance = 0.07, rewardMultiplier = 1.1 },
	},

	Wildfire = {
		id = "wildfire",
		displayName = "Wildfire",
		description = "Hot winds strain wooden defenses but improve visibility around burning areas.",
		stats = { woodStructureDamageMultiplier = 1.12, visibilityMultiplier = 1.1 },
		costs = {},
		tuning = { baseChance = 0.05, rewardMultiplier = 1.14 },
	},
}

return Omens
