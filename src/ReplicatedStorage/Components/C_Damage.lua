local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Damage", function(init: { amount: number?, source: Instance? })
	return {
		amount = init.amount or 0,
		source = init.source,
	}
end)
