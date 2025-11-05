local ReplicatedStorage = game:GetService("ReplicatedStorage")
local BeaconAura = require(ReplicatedStorage.Components.C_BeaconAura)

return function(world: any, dt: number?)
	-- TODO: Integrate with BeaconService to apply aura weaken multipliers.
	for id, aura in world:query(BeaconAura) do
		-- Placeholder: ensure radius remains within reasonable bounds.
		aura.radius = math.max(0, aura.radius)
	end
end
