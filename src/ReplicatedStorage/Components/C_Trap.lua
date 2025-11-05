local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Trap", function(init: { trapType: string?, cooldown: number?, lastTriggerTick: number? })
	return {
		trapType = init.trapType or "",
		cooldown = init.cooldown or 0,
		lastTriggerTick = init.lastTriggerTick or -math.huge,
	}
end)
