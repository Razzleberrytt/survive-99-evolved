local GameConfig = require(game.ReplicatedStorage.Shared.Config.Game)

local function beaconPosition()
	local beacon = workspace:FindFirstChild("Beacon")
	if beacon and beacon:IsA("BasePart") then return beacon.Position end
	return Vector3.new(0, 0, 0)
end

return function(_world, dt)
	local goal = beaconPosition()
	for _, inst in ipairs(workspace:GetChildren()) do
		if inst:IsA("BasePart") and inst.Name:match("^Enemy_") then
			local speed = inst:GetAttribute("Speed") or (GameConfig.Enemies[inst:GetAttribute("Kind") or "Forager"] or GameConfig.Enemies.Forager).speed
			local delta = goal - inst.Position
			if delta.Magnitude > 3 then
				local step = delta.Unit * speed * dt
				inst.AssemblyLinearVelocity = Vector3.new(step.X / math.max(dt, 1 / 60), inst.AssemblyLinearVelocity.Y, step.Z / math.max(dt, 1 / 60))
			else
				inst.AssemblyLinearVelocity = Vector3.new(0, inst.AssemblyLinearVelocity.Y, 0)
			end
		end
	end
end
