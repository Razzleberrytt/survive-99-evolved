local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("Loot", function(init)
	return {
		shards = init.shards or 0
	}
end)
