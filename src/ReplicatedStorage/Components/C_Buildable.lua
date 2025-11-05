local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Buildable", function(init: { owner: Player?, buildType: string? })
	return {
		owner = init.owner,
		buildType = init.buildType or "",
	}
end)
