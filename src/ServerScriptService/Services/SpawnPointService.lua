local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local BeaconService = require(script.Parent.BeaconService)

local TAG = "EnemySpawn"
local FOLDER_NAME = "SpawnPoints"
local params = { AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, Costs = { HighCost = 2.0 } }

local M = {}
local spawnFolder
local ring = {}
local idx = 1

local KIND_RINGS = {
	Swarmling = { min = 70, max = 115 },
	Screecher = { min = 95, max = 150 },
	Bruiser = { min = 110, max = 175 },
	Sapper = { min = 120, max = 190 },
	Miniboss = { min = 155, max = 220 },
	Forager = { min = 85, max = 145 },
}

local function ensureFolder()
	spawnFolder = workspace:FindFirstChild(FOLDER_NAME)
	if not spawnFolder then
		spawnFolder = Instance.new("Folder")
		spawnFolder.Name = FOLDER_NAME
		spawnFolder.Parent = workspace
	end
	return spawnFolder
end

local function marker(cf, ringName)
	local p = Instance.new("Part")
	p.Name = "SpawnMarker_" .. ringName
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.Size = Vector3.new(3, 1, 3)
	p.CFrame = cf
	p:SetAttribute("SpawnRing", ringName)
	p.Parent = spawnFolder
	CollectionService:AddTag(p, TAG)
	return p
end

local function computePathLen(from, to)
	local pf = PathfindingService:CreatePath(params)
	pf:ComputeAsync(from, to)
	if pf.Status ~= Enum.PathStatus.Success then return nil end
	local pts = pf:GetWaypoints()
	local len = 0
	for i = 2, #pts do
		len += (pts[i].Position - pts[i - 1].Position).Magnitude
	end
	return len, pts
end

local function buildRing(name, count, radius, jitter, angleOffset)
	for i = 1, count do
		local th = ((i - 1) / count) * math.pi * 2 + angleOffset
		local r = radius + math.random(-jitter, jitter)
		local pos = Vector3.new(math.cos(th) * r, 0, math.sin(th) * r)
		marker(CFrame.new(pos), name)
	end
end

local function buildDefaultRing()
	-- Three uneven rings make attacks feel like they come from the whole map instead of a single circle.
	buildRing("Near", 14, 90, 18, 0)
	buildRing("Mid", 18, 140, 26, math.rad(7))
	buildRing("Far", 10, 195, 32, math.rad(13))
end

local function refresh()
	ring = {}
	ensureFolder()
	for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
		if inst:IsDescendantOf(workspace) and inst:IsA("BasePart") then
			table.insert(ring, inst)
		end
	end
	if #ring == 0 then
		buildDefaultRing()
		refresh()
	end
end

local function nextCandidate()
	if #ring == 0 then refresh() end
	local p = ring[idx]
	idx += 1
	if idx > #ring then idx = 1 end
	return p
end

local function jittered(cf)
	local offset = Vector3.new(math.random(-8, 8), 0, math.random(-8, 8))
	return CFrame.new(cf.Position + offset)
end

function M.GetValidatedSpawn(minLen, maxTries, maxLen)
	minLen = minLen or 80
	maxTries = maxTries or math.max(#ring, 1)
	local tries = 0
	while tries < maxTries do
		tries += 1
		local part = nextCandidate()
		if not part then break end
		local len = computePathLen(part.Position, BeaconService.GetCFrame().Position)
		if len and len >= minLen and (not maxLen or len <= maxLen) then
			return jittered(part.CFrame)
		end
	end
	return (ring[1] and jittered(ring[1].CFrame)) or CFrame.new(0, 0, -120)
end

function M.GetSpawnForKind(kind)
	local range = KIND_RINGS[kind] or KIND_RINGS.Forager
	return M.GetValidatedSpawn(range.min, math.max(#ring * 2, 8), range.max)
end

function M.AllSpawnParts()
	if #ring == 0 then refresh() end
	return ring
end

refresh()
return M
