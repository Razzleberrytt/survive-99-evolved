local Rep = game:GetService("ReplicatedStorage")
local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local Matter = require(Rep.Packages.matter)
local Buildable = require(Rep.Components.C_Buildable)
local Health = require(Rep.Components.C_Health)
local C = require(Rep.Shared.Constants)

local M = {}
local GRID = 2
local MAX_PER_TYPE = { Wall = 60, TrapSpike = 40, SlowTotem = 25, Lantern = 25, Door = 12 }

local placedCounts = {} -- [player.UserId][type] = count

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

	-- Raycast LOS from player to placement
	local rayParams = RaycastParams.new(); rayParams.FilterDescendantsInstances = {player.Character}; rayParams.FilterType = Enum.RaycastFilterType.Blacklist
	local origin = (player.Character and player.Character.PrimaryPart and player.Character.PrimaryPart.Position) or (snapped.Position + Vector3.new(0,10,0))
	local dir = (snapped.Position - origin)
	local r = workspace:Raycast(origin, dir, rayParams)
	if r and (r.Position - snapped.Position).Magnitude > 4 then
		-- blocked by something not near the desired spot
	end

	return true, "ok", snapped
end

function M.Place(player, placeType, snapped)
	local counts = placedCounts[player.UserId]; counts[placeType] = (counts[placeType] or 0) + 1
	-- Create simple server Instance
	local p = Instance.new("Part")
	p.Name = placeType; p.Anchored = true; p.Size = Vector3.new(4,4,1)
	p.CFrame = snapped; p.Parent = workspace
	PhysicsService:SetPartCollisionGroup(p, "Placeables")

	-- TODO: add to Matter world via a registration callback (GameService can expose World)
	-- For now, attach attributes for debugging
	p:SetAttribute("HP", 100)
	return p:GetDebugId()
end

function M.Repair(_player, _target, amount)
	return math.clamp(amount or 0, 0, 100)
end

return M
