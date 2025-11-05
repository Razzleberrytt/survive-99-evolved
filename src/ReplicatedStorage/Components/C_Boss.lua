local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("Boss", function(init)
	return {
		stompCd = 0,  -- current cooldown
		stompMax = init.stompMax or 6, -- seconds between stomps
		telegraph = 1.2, -- seconds pre-warn
	}
end)
