-- Boss definitions for milestone encounters. Boss spawning, rewards, and damage are server-authoritative.

local Bosses = {
	HollowBrute = {
		id = "hollow_brute",
		displayName = "Hollow Brute",
		description = "First major siege boss that tests walls, repairs, and team focus fire.",
		stats = { health = 2200, speed = 7, damage = 45, attackRange = 8 },
		costs = { waveBudget = 80 },
		tuning = { milestoneNight = 10, structureDamageMultiplier = 1.6, essenceReward = 1 },
	},

	LanternEater = {
		id = "lantern_eater",
		displayName = "Lantern Eater",
		description = "Darkness boss that disables exposed lights and pressures map awareness.",
		stats = { health = 3200, speed = 9, damage = 36, attackRange = 12 },
		costs = { waveBudget = 110 },
		tuning = { milestoneNight = 25, lightDrainRadius = 45, essenceReward = 2 },
	},

	StormMaw = {
		id = "storm_maw",
		displayName = "Storm Maw",
		description = "Late-campaign boss that combines area denial with structure pressure.",
		stats = { health = 5200, speed = 8, damage = 52, attackRange = 14 },
		costs = { waveBudget = 155 },
		tuning = { milestoneNight = 50, stormPulseCooldown = 12, essenceReward = 3 },
	},

	FinalEntity = {
		id = "final_entity",
		displayName = "Final Entity",
		description = "Night 99 climax encounter that tests every survival system before escape.",
		stats = { health = 9900, speed = 10, damage = 65, attackRange = 16 },
		costs = { waveBudget = 300 },
		tuning = { milestoneNight = 99, phaseCount = 3, essenceReward = 10 },
	},
}

return Bosses
