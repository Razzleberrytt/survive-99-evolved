local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Health = require(ReplicatedStorage.Components.C_Health)

return function(world: any)
	-- TODO: Build and cache a coarse threat grid updated from entity signals.
	for id, health in world:query(Health) do
		if health.hp < health.max then
			-- TODO: accumulate weakened cell signal for squad planners.
		end
	end
end
