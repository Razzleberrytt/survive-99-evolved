local Matter = require(game:GetService("ReplicatedStorage").Packages.matter)

return Matter.component("Position", function(init: { cframe: CFrame? })
	return {
		cframe = init.cframe or CFrame.new(),
	}
end)
