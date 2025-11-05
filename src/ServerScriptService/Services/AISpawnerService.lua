local Rep = game:GetService("ReplicatedStorage")
local C = require(Rep.Shared.Constants)

local M = {}
local active = 0

local function spawnEnemy(enemyType, position)
	local p = Instance.new("Part")
	p.Name = enemyType
	p.Size = Vector3.new(2,3,1)
	p.Color = Color3.fromRGB(200, 60, 60)
	p.Anchored = false
	p.Position = position + Vector3.new(0,2,0)
	p.Parent = workspace
	active += 1
	p.Destroying:Connect(function() active -= 1 end)
	return p
end

function M.spawn(plan)
	-- naive ring spawn around origin; replace with real spawn points later
	local origin = Vector3.new(0,0,0)
	for _, s in ipairs(plan.squads) do
		for i = 1, s.count do
			if active >= C.MaxNPCs then return end
			local r = math.random(90, 150)
			local theta = math.random() * math.pi * 2
			local pos = origin + Vector3.new(math.cos(theta)*r, 0, math.sin(theta)*r)
			spawnEnemy(s.type, pos)
		end
	end
end

return M
