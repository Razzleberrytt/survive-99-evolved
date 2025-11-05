local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Attack = require(Rep.Components.C_Attack)
local EnemyType = require(Rep.Components.C_EnemyType)
local Health = require(Rep.Components.C_Health)
local Buildable = require(Rep.Components.C_Buildable)

-- Simple shared storage for structure instances -> health component
local structureRefs = {}

return function(world, dt)
	-- Rebuild a small map of structure instances (one pass)
	structureRefs = {}
	for sid, bref, bhp, b in world:query(InstanceRef, Health, Buildable) do
		if bref.inst then structureRefs[bref.inst] = { id = sid, hp = bhp } end
	end

	for id, ref, atk, et in world:query(InstanceRef, Attack, EnemyType) do
		if atk.cd > 0 then atk.cd -= dt end
		local inst = ref.inst
		if not inst then continue end
		-- Look for nearest structure within radius
		local nearest, dist = nil, atk.radius + 0.01
		for sInst, data in pairs(structureRefs) do
			local d = (sInst.Position - inst.Position).Magnitude
			if d < dist then nearest, dist = data, d end
		end
		if nearest and atk.cd <= 0 then
			nearest.hp.hp = math.max(0, nearest.hp.hp - atk.damage)
			atk.cd = atk.cooldown
			if nearest.hp.hp <= 0 then
				-- Despawn structure entity (server cleans up instance)
				world:despawn(nearest.id)
				if sInst and sInst.Parent then sInst:Destroy() end
			end
		end
	end
end
