local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Attack = require(Rep.Components.C_Attack)
local EnemyType = require(Rep.Components.C_EnemyType)
local Health = require(Rep.Components.C_Health)
local Buildable = require(Rep.Components.C_Buildable)
local Net = require(Rep.Remotes.Net)

local structureRefs = {} -- [BasePart] = { id, hpC }

return function(world, dt)
	-- Map structures
	structureRefs = {}
	for sid, bref, bhp, b in world:query(InstanceRef, Health, Buildable) do
		if bref.inst then structureRefs[bref.inst] = { id = sid, hpC = bhp } end
	end

	for id, ref, atk, et in world:query(InstanceRef, Attack, EnemyType) do
		if atk.cd > 0 then atk.cd -= dt end
		local inst = ref.inst
		if not inst then continue end

		local nearest, nearestInst, dist = nil, nil, atk.radius + 0.01
		for sInst, data in pairs(structureRefs) do
			local d = (sInst.Position - inst.Position).Magnitude
			if d < dist then nearest, nearestInst, dist = data, sInst, d end
		end

		if nearest and atk.cd <= 0 then
			nearest.hpC.hp = math.max(0, nearest.hpC.hp - atk.damage)
			atk.cd = atk.cooldown
			-- VFX
			Net.SpawnVFX:FireAllClients({ kind = "damage", part = nearestInst, amount = atk.damage })

			if nearest.hpC.hp <= 0 then
				if nearestInst and nearestInst.Parent then nearestInst:Destroy() end
				world:despawn(nearest.id)
			end
		end
	end
end
