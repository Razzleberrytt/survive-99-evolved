local Rep = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local PhysicsService = game:GetService("PhysicsService")

local BeaconService = require(script.Parent.BeaconService)
local WorldRegistry = require(Rep.Shared.WorldRegistry)

local Matter = require(Rep.Packages.matter)
local Buildable = require(Rep.Components.C_Buildable)
local Health = require(Rep.Components.C_Health)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Trap = require(Rep.Components.C_Trap)

local Net = require(Rep.Remotes.Net)

local M = {}
local GRID = 2
local MAX_PER_TYPE = { Wall = 60, TrapSpike = 40, SlowTotem = 25, Lantern = 25, Door = 12 }
local TOTAL_CAP = 120

local placedCounts = {}       -- [userId][type] = count
local globalCount = 0

local function snapVec3(v) return Vector3.new(math.round(v.X/GRID)*GRID, math.round(v.Y/GRID)*GRID, math.round(v.Z/GRID)*GRID) end
local function dist(a,b) return (a-b).Magnitude end

local function overlapsBox(cf, size)
	local region = Region3.new(cf.Position - size/2, cf.Position + size/2)
	region = region:ExpandToGrid(GRID)
	local parts = Workspace:FindPartsInRegion3(region, nil, math.huge)
	for _, p in ipairs(parts) do
		if p.CanCollide and p.Anchored and p.Name ~= "Terrain" then
			return true
		end
	end
	return false
end

local function losFromCharacter(player, point)
	local char = player.Character
	if not (char and char.PrimaryPart) then return true end
	local origin = char.PrimaryPart.Position + Vector3.new(0, 2, 0)
	local dir = point - origin
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Blacklist
	params.FilterDescendantsInstances = { char }
	local hit = Workspace:Raycast(origin, dir, params)
	if not hit then return true end
	-- allow hit if within 3 studs of target (placing on that surface)
	return (hit.Position - point).Magnitude <= 3
end

function M.ValidatePlacement(player, placeType, cf)
	placeType = placeType or "Wall"
	local counts = placedCounts[player.UserId] or {}; placedCounts[player.UserId] = counts
	local limit = MAX_PER_TYPE[placeType] or 30
	if globalCount >= TOTAL_CAP then return false, "cap_reached" end
	if (counts[placeType] or 0) >= limit then return false, "type_limit" end

	local snapped = CFrame.new(snapVec3(cf.Position))
	-- distance to beacon
	local beaconPos = BeaconService.GetCFrame().Position
	if dist(snapped.Position, beaconPos) > 220 then return false, "too_far" end
	-- LOS
	if not losFromCharacter(player, snapped.Position) then return false, "no_los" end
	-- collision (simple region)
	local size = (placeType=="Wall") and Vector3.new(4,4,1) or Vector3.new(4,2,4)
	if overlapsBox(snapped, size) then return false, "blocked" end

	return true, "ok", snapped
end

local function createStructureInstance(placeType, cf)
	local p = Instance.new("Part")
	p.Name = placeType; p.Anchored = true; p.Size = (placeType=="Wall") and Vector3.new(4,4,1) or Vector3.new(4,2,4)
	p.CFrame = cf; p.Parent = workspace
	PhysicsService:SetPartCollisionGroup(p, "Placeables")
	p:SetAttribute("HP", (placeType=="Wall") and 180 or 120)
	return p
end

function M.Place(player, placeType, cf)
	local ok, reason, snapped = M.ValidatePlacement(player, placeType, cf)
	if not ok then return nil end

	local counts = placedCounts[player.UserId]; counts[placeType] = (counts[placeType] or 0) + 1
	globalCount += 1

	local p = createStructureInstance(placeType, snapped)
	local world = WorldRegistry.get()
	if world then
		local comps = {
			Buildable({ owner = player.UserId, type = placeType }),
			Health({ hp = p:GetAttribute("HP"), max = p:GetAttribute("HP") }),
			InstanceRef({ inst = p }),
		}
		if placeType == "TrapSpike" then
			table.insert(comps, Trap({ kind = "Spike", cooldown = 0 }))
		elseif placeType == "SlowTotem" then
			table.insert(comps, Trap({ kind = "Slow", cooldown = 0 }))
		end
		world:spawn(table.unpack(comps))
	end

	-- Tutorial hook (non-fatal)
	pcall(function()
		require(script.Parent.TutorialService).OnAction(player, "place")
	end)

	return p:GetDebugId()
end

function M.Repair(player, targetId, amount)
	-- MVP: just returns clamped amount; structure HP is server-managed elsewhere
	local n = math.clamp(amount or 0, 0, 100)
	return n
end

return M
