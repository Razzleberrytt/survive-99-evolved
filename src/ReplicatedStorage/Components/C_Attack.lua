local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("Attack", function(init)
	return {
		damage = init.damage or 8,
		radius = init.radius or 4,
		cooldown = init.cooldown or 1.2,
		cd = 0,
	}
end)
