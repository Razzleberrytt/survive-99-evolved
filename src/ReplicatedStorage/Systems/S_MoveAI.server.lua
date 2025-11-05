local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Motion = require(Rep.Components.C_Motion)
local PathComp = require(Rep.Components.C_Path)
local Target = require(Rep.Components.C_Target)

return function(world, dt)
	for id, ref, mot, path, tgt in world:query(InstanceRef, Motion, PathComp, Target) do
		local inst = ref.inst
		if not (inst and inst:IsA("BasePart")) then continue end

		local goal = nil
		if path.points and path.points[path.i] then
			goal = path.points[path.i]
			-- advance when close
			if (goal - inst.Position).Magnitude < 4 then
				path.i += 1
				goal = path.points[path.i]
			end
		elseif tgt and tgt.target then
			goal = tgt.target
		end

		if goal then
			local dir = (goal - inst.Position)
			if dir.Magnitude > 1 then
				local v = dir.Unit * mot.speed
				inst.AssemblyLinearVelocity = Vector3.new(v.X, inst.AssemblyLinearVelocity.Y, v.Z)
			else
				inst.AssemblyLinearVelocity *= Vector3.new(0.4,1,0.4)
			end
		end
	end
end
