local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Health = require(ReplicatedStorage.Components.C_Health)
local Buildable = require(ReplicatedStorage.Components.C_Buildable)

return function(world: any, dt: number?)
	-- TODO: Resolve queued damage events from AI and traps onto structures.
	for id, health, buildable in world:query(Health, Buildable) do
		if health.hp <= 0 then
			-- TODO: handle destruction (drop loot, notify services)
		end
	end
end
