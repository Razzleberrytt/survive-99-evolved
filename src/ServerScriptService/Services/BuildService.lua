local Rep = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local Matter = require(Rep.Packages.matter)
local WorldRegistry = require(Rep.Shared.WorldRegistry)

local Buildable = require(Rep.Components.C_Buildable)
local Health = require(Rep.Components.C_Health)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Trap = require(Rep.Components.C_Trap)

local M = {}
local GRID = 2
local MAX_PER_TYPE = { Wall = 60, TrapSpike = 40, SlowTotem = 25, Lantern = 25, Door = 12 }
local placedCounts = {} -- [userId][type] = count

local function snapVec3(v) return Vector3.new(math.round(v.X/GRID)*GRID, math.round(v.Y/GRID)*GRID, math.round(v.Z/GRID)*GRID) end
local function dist(a,b) return (a-b).Magnitude end

function M.ValidatePlacement(player, placeType, cf)
	placeType = placeType or "Wall"
	local counts = placedCounts[player.UserId] or {}; placedCounts[player.UserId] = counts
	local limit = MAX_PER_TYPE[placeType] or 30
	if (counts[placeType] or 0) >= limit then return false, "limit" end
	local snapped = CFrame.new(snapVec3(cf.Position))
	local beaconPos = BeaconService.GetCFrame().Position
	if dist(snapped.Position, beaconPos) > 220 then return false, "too_far" end
	return true, "ok", snapped
end

local function createStructureInstance(placeType, cf)
	local p = Instance.new("Part")
	p.Name = placeType; p.Anchored = true; p.Size = (placeType=="Wall") and Vector3.new(4,4,1) or Vector3.new(4,2,4)
	p.CFrame = cf; p.Parent = workspace
	PhysicsService:SetPartCollisionGroup(p, "Placeables")
	return p
end

function M.Place(player, placeType, cf)
	local counts = placedCounts[player.UserId]; counts[placeType] = (counts[placeType] or 0) + 1

	local p = createStructureInstance(placeType, cf)
	local world = WorldRegistry.get(); if not world then return p:GetDebugId() end

	-- Health values
	local hp = (placeType=="Wall") and 180 or 120
	local comps = {
		Buildable({ owner = player.UserId, type = placeType }),
		Health({ hp = hp, max = hp }),
		InstanceRef({ inst = p }),
	}

	if placeType == "TrapSpike" then
		table.insert(comps, Trap({ kind = "Spike", cooldown = 2 }))
	elseif placeType == "SlowTotem" then
		table.insert(comps, Trap({ kind = "Slow", cooldown = 0 }))
	end

	world:spawn(table.unpack(comps))
	return p:GetDebugId()
end

function M.Repair(_player, _target, amount)
	return math.clamp(amount or 0, 0, 100)
end

return M
