local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Trap", function(init)
	local kind = init.kind or init.trapType or ""
	return {
		kind = kind,
		cooldown = init.cooldown or 0,
		lastTriggerTick = init.lastTriggerTick or -math.huge,
	}
end)
