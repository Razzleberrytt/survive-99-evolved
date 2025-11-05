local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("BeaconAura", function(init: { radius: number?, weakenMultiplier: number? })
	return {
		radius = init.radius or 100,
		weakenMultiplier = init.weakenMultiplier or 0.9,
	}
end)
