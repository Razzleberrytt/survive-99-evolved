local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("AIState", function(init: { state: string?, lastOrderTick: number? })
	return {
		state = init.state or "Idle",
		lastOrderTick = init.lastOrderTick or 0,
	}
end)
