local PathfindingService = game:GetService("PathfindingService")
local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Target = require(Rep.Components.C_Target)
local PathComp = require(Rep.Components.C_Path)

local AGENT_PARAMS = {
	AgentRadius = 2, AgentHeight = 5, AgentCanJump = true
}

local function computePath(from, to)
	local pf = PathfindingService:CreatePath(AGENT_PARAMS)
	pf:ComputeAsync(from, to)
	if pf.Status ~= Enum.PathStatus.Success then return nil end
	local pts = {}
	for _, wp in ipairs(pf:GetWaypoints()) do table.insert(pts, wp.Position) end
	return pts
end

return function(world, dt)
	for id, ref, tgt, path in world:query(InstanceRef, Target, PathComp) do
		if not (ref.inst and tgt.target) then
			path.points, path.i, path.rethink = {}, 1, 0
			continue
		end
		path.rethink -= dt
		local need = (#path.points == 0) or (path.i > #path.points) or (path.rethink <= 0)
		if need then
			local pts = computePath(ref.inst.Position, tgt.target)
			if pts then
				path.points = pts
				path.i = 1
				path.rethink = 1 + math.random() * 0.5  -- stagger recomputes
			else
				path.points, path.i, path.rethink = {}, 1, 0.5
			end
		end
	end
end
