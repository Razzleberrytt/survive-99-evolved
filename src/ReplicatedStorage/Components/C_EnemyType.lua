local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("EnemyType", function(init)
	return { kind = init.kind or "Forager", speed = init.speed or 12 }
end)
