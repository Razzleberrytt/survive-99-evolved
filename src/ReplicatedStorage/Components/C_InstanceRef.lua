local Matter = require(game.ReplicatedStorage.Packages.matter)
return Matter.component("InstanceRef", function(init)
	return { inst = init.inst } -- Roblox Instance (Part/Model)
end)
