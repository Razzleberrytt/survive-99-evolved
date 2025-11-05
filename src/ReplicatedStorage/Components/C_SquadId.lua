local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("SquadId", function(init: { id: string? })
	return {
		id = init.id or "",
	}
end)
