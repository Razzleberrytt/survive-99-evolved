local CollectionService = game:GetService("CollectionService")
local PathfindingService = game:GetService("PathfindingService")
local Rep = game:GetService("ReplicatedStorage")
local BeaconService = require(script.Parent.BeaconService)

local TAG = "EnemySpawn"
local FOLDER_NAME = "SpawnPoints"
local params = { AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, Costs = { HighCost = 2.0 } }

local M = {}
local spawnFolder
local ring = {}   -- {BasePart}
local idx = 1

local function ensureFolder()
	spawnFolder = workspace:FindFirstChild(FOLDER_NAME)
	if not spawnFolder then
		spawnFolder = Instance.new("Folder")
		spawnFolder.Name = FOLDER_NAME
		spawnFolder.Parent = workspace
	end
	return spawnFolder
end

local function marker(cf)
	local p = Instance.new("Part")
	p.Name = "SpawnMarker"
	p.Anchored = true
	p.CanCollide = false
	p.Transparency = 1
	p.Size = Vector3.new(2,1,2)
	p.CFrame = cf
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
	for i = 2, #pts do len += (pts[i].Position - pts[i-1].Position).Magnitude end
	return len, pts
end

local function buildDefaultRing()
	-- Build if none exist: 24 points around origin at r=120 ± jitter
	local count = 24
	local r = 120
	for i = 1, count do
		local th = (i-1)/count * math.pi*2
		local j = math.random(-10,10)
		local pos = Vector3.new(math.cos(th)*(r+j), 0, math.sin(th)*(r+j))
		marker(CFrame.new(pos))
	end
end

local function refresh()
	ring = {}
	ensureFolder()
	for _, inst in ipairs(CollectionService:GetTagged(TAG)) do
		if inst:IsDescendantOf(workspace) and inst:IsA("BasePart") then
			table.insert(ring, inst)
		end
	end
	if #ring == 0 then buildDefaultRing(); refresh() end
end

local function nextCandidate()
	if #ring == 0 then refresh() end
	local p = ring[idx]; idx += 1; if idx > #ring then idx = 1 end
	return p
end

function M.GetValidatedSpawn(minLen, maxTries)
	minLen = minLen or 80
	maxTries = maxTries or #ring
	local tries = 0
	while tries < maxTries do
		tries += 1
		local part = nextCandidate()
		if not part then break end
		local len = computePathLen(part.Position, BeaconService.GetCFrame().Position)
		if len and len >= minLen then
			return part.CFrame
		end
	end
	return (ring[1] and ring[1].CFrame) or CFrame.new(0,0,-120)
end

function M.AllSpawnParts()
	if #ring == 0 then refresh() end
	return ring
end

-- init
refresh()
return M
