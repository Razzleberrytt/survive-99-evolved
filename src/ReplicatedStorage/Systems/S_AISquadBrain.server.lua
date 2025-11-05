local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AIState = require(ReplicatedStorage.Components.C_AIState)
local Health = require(ReplicatedStorage.Components.C_Health)

return function(world: any, dt: number?)
	-- TODO: integrate with AIService order queue once implemented.
	for id, ai, health in world:query(AIState, Health) do
		-- Placeholder: basic state transitions based on health thresholds.
		if health.hp <= 0 then
			ai.state = "Defeated"
		elseif health.hp < (0.25 * health.max) then
			ai.state = "Retreat"
		elseif ai.state == "Idle" then
			ai.state = "Probe"
		end
	end
end
