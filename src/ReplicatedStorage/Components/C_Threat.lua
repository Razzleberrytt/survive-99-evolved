local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Threat", function(init: { level: number? })
	return {
		level = init.level or 0,
	}
end)
