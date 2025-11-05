local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Health", function(init: { hp: number?, max: number? })
	local max = init.max or 100
	return {
		hp = init.hp or max,
		max = max,
	}
end)
