return {
	Wave = {
		BaseBudget = { [1] = 40, [2] = 70, [3] = 100 },
		TeamFactor = 0.35,
		MicroWaves = { min = 6, max = 8, gap = { 10, 20 } },
		EnemyCosts = { Swarmling = 4, Forager = 6, Screecher = 10, Bruiser = 14, Sapper = 16, Miniboss = 60 },
	},
	AI = {
		ThinkHz = 10,
		FarHz = { min = 2, max = 5 },
		FarDist = 60,
		SleepDist = 150,
	},
	Enemies = {
		Forager = { hp = 90, speed = 13, damage = 7, range = 4, cooldown = 1.15, shards = 1, xp = 6, ring = "Mid", state = "Probe" },
		Swarmling = { hp = 45, speed = 17, damage = 4, range = 3, cooldown = 0.8, shards = 1, xp = 4, ring = "Near", state = "Flank" },
		Bruiser = { hp = 190, speed = 9, damage = 18, range = 5, cooldown = 1.45, shards = 2, xp = 12, ring = "Mid", state = "FocusBeacon" },
		Screecher = { hp = 70, speed = 14, damage = 3, range = 10, cooldown = 2.4, shards = 2, xp = 9, ring = "Mid", state = "Flank" },
		Sapper = { hp = 80, speed = 12, damage = 0, range = 4, cooldown = 1.8, shards = 3, xp = 14, ring = "Far", state = "FocusBeacon" },
		Miniboss = { hp = 650, speed = 8, damage = 26, range = 7, cooldown = 1.0, shards = 8, xp = 80, ring = "Far", state = "FocusBeacon", boss = true },
	},
	Survival = {
		MaxHealth = 100,
		MaxStamina = 100,
		HungerDrain = 0.55,
		ThirstDrain = 0.85,
		StaminaRegen = 16,
		StarveDamage = 3,
		RegenHealth = 1.5,
		RegenNeed = 35,
	},
	Weapons = {
		melee = { cooldown = 0.65, range = 7, damage = 28, stamina = 12 },
		pistol = { cooldown = 0.3, range = 120, damage = 18, spread = 1.5, stamina = 4 },
	},
}
