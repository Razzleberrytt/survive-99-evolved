local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("Path", function(init)
	return {
		points = init.points or {}, -- {Vector3}
		i = init.i or 1,            -- current waypoint index
		rethink = 0,                -- secs until recompute
	}
end)
