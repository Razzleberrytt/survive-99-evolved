local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Despawn = require(ReplicatedStorage.Components.C_Despawn)

return function(world: any, dt: number?)
	if not dt then
		dt = 0
	end
	for id, despawn in world:query(Despawn) do
		despawn.timeRemaining -= dt
		if despawn.timeRemaining <= 0 then
			world:despawn(id)
		end
	end
end
