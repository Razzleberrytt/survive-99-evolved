local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("Motion", function(init)
	return { speed = init.speed or 12 }
end)
