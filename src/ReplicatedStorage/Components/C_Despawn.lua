local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Despawn", function(init: { timeRemaining: number? })
	return {
		timeRemaining = init.timeRemaining or 0,
	}
end)
