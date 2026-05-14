local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Target", function(init: { instance: Instance?, position: Vector3?, target: Vector3? })
	return {
		instance = init.instance,
		position = init.position,
		target = init.target or init.position,
	}
end)
