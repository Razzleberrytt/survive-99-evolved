local Store = {
	-- Map Developer Product IDs to award handlers/labels.
	-- Replace example IDs with real ones from Roblox portal.
	Products = {
		[1001] = { key = "CashSmall", amount = 500 },
		[1002] = { key = "CashMedium", amount = 1500 },
		[1003] = { key = "CashLarge", amount = 5000 },
	},
	-- Optional GamePass mapping if used:
	GamePasses = {
		-- [2001] = { key = "VIP", grant = function(player) end }
	},
}
return Store
