local Rep = game:GetService("ReplicatedStorage")
local AIState = require(Rep.Components.C_AIState)
local Matter = require(Rep.Packages.matter)
return function(world, dt)
	for id, ai in world:query(AIState) do
		-- TODO: integrate with AIService.SendPerceptionAndGetOrders
		-- For now, keep state cycling every few seconds (placeholder)
		ai.lastOrderTick += dt
		if ai.lastOrderTick > 5 then
			ai.state = (ai.state == "Probe") and "FocusBeacon" or "Probe"
			ai.lastOrderTick = 0
		end
	end
end
