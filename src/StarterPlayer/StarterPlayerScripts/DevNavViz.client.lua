local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local enabled = false
local adorns = {}

local function clear()
	for _, a in ipairs(adorns) do if a and a.Parent then a:Destroy() end end
	table.clear(adorns)
end

local function box(part, filled)
	local a = Instance.new("BoxHandleAdornment")
	a.Adornee = part
	a.AlwaysOnTop = true
	a.Size = part.Size + Vector3.new(0.1,0.1,0.1)
	a.Transparency = filled and 0.8 or 0.2
	a.ZIndex = 1
	a.Parent = workspace
	table.insert(adorns, a)
end

local function dot(part)
	local a = Instance.new("SphereHandleAdornment")
	a.Adornee = part
	a.AlwaysOnTop = true
	a.Radius = 1.1
	a.Transparency = 0.1
	a.ZIndex = 0
	a.Parent = workspace
	table.insert(adorns, a)
end

local function refresh()
	clear()
	-- Spawn points
	for _, p in ipairs(CollectionService:GetTagged("EnemySpawn")) do
		if p:IsA("BasePart") then dot(p) end
	end
	-- Nav volumes
	local root = workspace:FindFirstChild("NavVolumes")
	if root then
		for _, ch in ipairs(root:GetDescendants()) do
			if ch:IsA("BasePart") then box(ch, true) end
		end
	end
end

Players.LocalPlayer.Chatted:Connect(function(msg)
	if msg:lower():match("^/navviz") then
		enabled = not enabled
		if enabled then refresh() else clear() end
	end
	if msg:lower():match("^/genspawns") then
		-- Force server to recreate default ring by removing folder (dev only, safe in Studio)
		local f = workspace:FindFirstChild("SpawnPoints")
		if f then f:Destroy() end
	end
end)
