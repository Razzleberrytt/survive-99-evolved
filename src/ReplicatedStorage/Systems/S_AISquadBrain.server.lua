local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local AIState = require(Rep.Components.C_AIState)
local Target = require(Rep.Components.C_Target)
local EnemyType = require(Rep.Components.C_EnemyType)

local BeaconService = require(game.ServerScriptService.Services.BeaconService)

local function randomAround(cf, radius)
	local ang = math.random() * math.pi * 2
	return cf.Position + Vector3.new(math.cos(ang), 0, math.sin(ang)) * radius
end

return function(world, dt)
	for id, ai, tgt, et in world:query(AIState, Target, EnemyType) do
		ai.lastOrderTick += dt
		if not tgt.target or ai.lastOrderTick > 3 then
			local beaconCF = BeaconService.GetCFrame()
			local behavior = ai.state
			if behavior == "FocusBeacon" then
				tgt.target = beaconCF.Position
			elseif behavior == "Flank" then
				tgt.target = randomAround(beaconCF, 30 + math.random(0, 30))
			elseif behavior == "Retreat" then
				tgt.target = randomAround(beaconCF, 160 + math.random(0, 40))
			else -- Probe
				tgt.target = randomAround(beaconCF, 80 + math.random(0, 60))
			end
			ai.lastOrderTick = 0
		end
	end
end
