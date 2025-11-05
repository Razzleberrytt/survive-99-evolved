local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local C = require(Rep.Shared.Constants)
local WorldRegistry = require(Rep.Shared.WorldRegistry)

local EnemyType = require(Rep.Components.C_EnemyType)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local AIState = require(Rep.Components.C_AIState)
local Health = require(Rep.Components.C_Health)
local Target = require(Rep.Components.C_Target)
local Motion = require(Rep.Components.C_Motion)
local Attack = require(Rep.Components.C_Attack)
local PathComp = require(Rep.Components.C_Path)
local Loot = require(Rep.Components.C_Loot)
local Boss = require(Rep.Components.C_Boss)

local M = {}
local active = 0

local SPEED_BY_KIND = {
	Forager = 14, Swarmling = 16, Bruiser = 10, Screecher = 13, Sapper = 12, Miniboss = 9,
}
local DMG_BY_KIND = {
	Forager = 6, Swarmling = 4, Bruiser = 16, Screecher = 2, Sapper = 0, Miniboss = 24,
}

local function makeEnemyPart(kind, position)
	local p = Instance.new("Part")
	p.Name = "Enemy_" .. kind
	p.Size = Vector3.new(2,3,2)
	p.Material = Enum.Material.SmoothPlastic
	p.Color = (kind=="Miniboss") and Color3.fromRGB(170,0,0) or Color3.fromRGB(200, 60, 60)
	p.Position = position + Vector3.new(0,2,0)
	p.Anchored = false
	p.CanCollide = true
	p.Parent = workspace
	local att = Instance.new("Attachment", p) att.Name = "Root"
	return p
end

local function spawnOne(kind, position)
	if active >= C.MaxNPCs then return end
	local world = WorldRegistry.get(); if not world then return end
	local part = makeEnemyPart(kind, position)
	active += 1
	part.Destroying:Connect(function() active -= 1 end)

	local speed = SPEED_BY_KIND[kind] or 12
	local dmg = DMG_BY_KIND[kind] or 6

	local comps = {
		EnemyType({ kind = kind, speed = speed }),
		InstanceRef({ inst = part }),
		AIState({ state = "Probe" }),
		Health({ hp = (kind=="Miniboss") and 600 or 100, max = (kind=="Miniboss") and 600 or 100 }),
		Target({ target = nil }),
		PathComp({ points = {}, i = 1, rethink = 0 }),
		Motion({ speed = speed }),
		Attack({ damage = dmg, radius = (kind=="Miniboss") and 6 or 4, cooldown = (kind=="Miniboss") and 1.0 or 1.2 }),
		Loot({ shards = (kind=="Miniboss") and 5 or 1 }),
	}
	if kind == "Miniboss" then table.insert(comps, Boss({stompMax=7})) end
	local id = world:spawn(table.unpack(comps))
	return id
end

function M.spawn(plan)
	local origin = Vector3.new(0,0,0)
	for _, s in ipairs(plan.squads) do
		for i = 1, s.count do
			if active >= C.MaxNPCs then return end
			local r = math.random(90, 150)
			local theta = math.random() * math.pi * 2
			local pos = origin + Vector3.new(math.cos(theta)*r, 0, math.sin(theta)*r)
			spawnOne(s.type, pos)
		end
	end
end

return M
