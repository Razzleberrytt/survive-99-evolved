-- Role definitions for Survive 99: Evolved.
-- These values are shared read-only tuning; all gameplay authority remains server-side.

local Roles = {
	Survivor = {
		id = "survivor",
		displayName = "Survivor",
		description = "Reliable all-rounder with balanced survival stats.",
		stats = {
			maxHealth = 100,
			walkSpeed = 16,
			stamina = 100,
			carryCapacity = 10,
		},
		tuning = {
			gatherMultiplier = 1.0,
			buildMultiplier = 1.0,
			reviveMultiplier = 1.0,
			combatMultiplier = 1.0,
		},
	},

	Builder = {
		id = "builder",
		displayName = "Builder",
		description = "Builds and repairs defenses faster while carrying more materials.",
		stats = {
			maxHealth = 105,
			walkSpeed = 15,
			stamina = 95,
			carryCapacity = 14,
		},
		tuning = {
			gatherMultiplier = 0.95,
			buildMultiplier = 1.25,
			repairMultiplier = 1.25,
			combatMultiplier = 0.95,
		},
	},

	Scout = {
		id = "scout",
		displayName = "Scout",
		description = "Moves quickly, explores safely, and spots objectives early.",
		stats = {
			maxHealth = 90,
			walkSpeed = 18,
			stamina = 125,
			carryCapacity = 8,
		},
		tuning = {
			gatherMultiplier = 1.05,
			scoutRadius = 1.35,
			sprintCostMultiplier = 0.85,
			combatMultiplier = 0.9,
		},
	},

	Medic = {
		id = "medic",
		displayName = "Medic",
		description = "Revives teammates faster and improves team recovery windows.",
		stats = {
			maxHealth = 95,
			walkSpeed = 16,
			stamina = 105,
			carryCapacity = 9,
		},
		tuning = {
			reviveMultiplier = 1.35,
			healMultiplier = 1.25,
			downTimerBonus = 5,
			combatMultiplier = 0.9,
		},
	},

	Hunter = {
		id = "hunter",
		displayName = "Hunter",
		description = "Specializes in combat, scouting threats, and collecting enemy drops.",
		stats = {
			maxHealth = 100,
			walkSpeed = 17,
			stamina = 110,
			carryCapacity = 9,
		},
		tuning = {
			combatMultiplier = 1.2,
			lootMultiplier = 1.1,
			threatSenseRadius = 1.2,
			buildMultiplier = 0.9,
		},
	},

	Engineer = {
		id = "engineer",
		displayName = "Engineer",
		description = "Improves powered structures, traps, and Beacon maintenance.",
		stats = {
			maxHealth = 95,
			walkSpeed = 16,
			stamina = 100,
			carryCapacity = 11,
		},
		tuning = {
			generatorEfficiency = 1.2,
			trapDurability = 1.15,
			beaconRepairMultiplier = 1.2,
			combatMultiplier = 0.95,
		},
	},
}

return Roles
