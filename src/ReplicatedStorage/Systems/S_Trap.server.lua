local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local Trap = require(Rep.Components.C_Trap)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local EnemyType = require(Rep.Components.C_EnemyType)
local Motion = require(Rep.Components.C_Motion)
local Net = require(Rep.Remotes.Net)

-- Simple spatial scan (O(n*m) is fine for MVP scale)

return function(world, dt)
	local traps = {}
	for tid, trap, tref in world:query(Trap, InstanceRef) do
		trap.cooldown = math.max(0, trap.cooldown - dt)
		table.insert(traps, { trap = trap, inst = tref.inst })
	end

	for eid, et, eref, mot in world:query(EnemyType, InstanceRef, Motion) do
		for _, t in ipairs(traps) do
			if t.inst and eref.inst then
				local d = (t.inst.Position - eref.inst.Position).Magnitude
				if t.trap.kind == "Spike" and d < 5 and t.trap.cooldown == 0 then
					-- Apply instant burst by reducing enemy HP through a component if present
					-- (MVP) just knock back via velocity
					local dir = (eref.inst.Position - t.inst.Position).Unit
					eref.inst.AssemblyLinearVelocity += dir * 24
					t.trap.cooldown = 2
					Net.SpawnVFX:FireAllClients({ kind="text", part = eref.inst, text = "SPIKED!" })
				elseif t.trap.kind == "Slow" and d < 10 then
					mot.speed = math.max(6, mot.speed * 0.6)
				end
			end
		end
	end
end
