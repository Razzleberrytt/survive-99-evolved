-- Shared resource definitions. Server code owns awarding, spending, and persistence validation.

local Resources = {
	Wood = {
		id = "wood",
		displayName = "Wood",
		description = "Basic building material gathered from trees and salvage piles.",
		category = "material",
		stats = {
			baseStackSize = 50,
			baseCarry = 30,
			weight = 1,
		},
		tuning = {
			commonness = 1.0,
			baseGatherAmount = 3,
		},
	},

	Scrap = {
		id = "scrap",
		displayName = "Scrap",
		description = "Metal salvage used for stronger defenses, traps, and utility structures.",
		category = "material",
		stats = {
			baseStackSize = 40,
			baseCarry = 20,
			weight = 1,
		},
		tuning = {
			commonness = 0.75,
			baseGatherAmount = 2,
		},
	},

	Food = {
		id = "food",
		displayName = "Food",
		description = "Consumable supply used for recovery, rescue events, and camp survival pressure.",
		category = "supply",
		stats = {
			baseStackSize = 30,
			baseCarry = 10,
			restoreHealth = 15,
		},
		tuning = {
			commonness = 0.85,
			spoilageEnabled = false,
		},
	},

	Fuel = {
		id = "fuel",
		displayName = "Fuel",
		description = "Beacon and generator fuel that keeps the camp protected during the night.",
		category = "beacon",
		stats = {
			baseStackSize = 25,
			baseCarry = 5,
			beaconEnergy = 10,
		},
		tuning = {
			commonness = 0.55,
			priorityPing = true,
		},
	},

	Shards = {
		id = "shards",
		displayName = "Shards",
		description = "Run-earned currency for non-pay-to-win progression and cosmetic rewards.",
		category = "currency",
		stats = {
			baseStackSize = 999,
		},
		tuning = {
			persistBetweenRuns = true,
			premium = false,
		},
	},

	Essence = {
		id = "essence",
		displayName = "Essence",
		description = "Rare boss and event reward used for prestige, cosmetics, and late-run upgrades.",
		category = "rareCurrency",
		stats = {
			baseStackSize = 999,
			baseCarry = 3,
		},
		tuning = {
			persistBetweenRuns = true,
			rarity = "rare",
		},
	},
}

function Resources.GetCarryCaps()
	local caps = {}
	for resourceType, resourceConfig in pairs(Resources) do
		if typeof(resourceConfig) == "table" and resourceConfig.stats and resourceConfig.stats.baseCarry then
			caps[resourceType] = resourceConfig.stats.baseCarry
		end
	end
	return caps
end

return Resources
