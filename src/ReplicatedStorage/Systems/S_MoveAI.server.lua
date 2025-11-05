local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Target = require(Rep.Components.C_Target)
local Motion = require(Rep.Components.C_Motion)

return function(world, dt)
	for id, ref, tgt, mot in world:query(InstanceRef, Target, Motion) do
		local inst = ref.inst
		if inst and inst:IsA("BasePart") and tgt.target then
			local dir = (tgt.target - inst.Position)
			if dir.Magnitude > 1 then
				local v = dir.Unit * mot.speed
				inst.AssemblyLinearVelocity = Vector3.new(v.X, inst.AssemblyLinearVelocity.Y, v.Z)
			else
				inst.AssemblyLinearVelocity = inst.AssemblyLinearVelocity * Vector3.new(0.4,1,0.4)
			end
		end
	end
end
