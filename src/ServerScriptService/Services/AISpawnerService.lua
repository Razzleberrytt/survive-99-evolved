local Rep = game:GetService("ReplicatedStorage")
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

local AssetLoader = require(script.Parent.AssetLoader)
local SpawnPoints = require(script.Parent.SpawnPointService)
local OmenService = require(script.Parent.OmenService)
local Tuning = require(Rep.Shared.Config.Tuning)
local GameConfig = require(Rep.Shared.Config.Game)

local M = {}
local active = 0

local ENEMIES = GameConfig.Enemies

local KIND_COLOR = {
	Forager = Color3.fromRGB(205, 75, 60),
	Swarmling = Color3.fromRGB(220, 110, 55),
	Bruiser = Color3.fromRGB(145, 50, 50),
	Screecher = Color3.fromRGB(130, 75, 200),
	Sapper = Color3.fromRGB(210, 165, 55),
	Miniboss = Color3.fromRGB(170, 0, 0),
}

local function profileFor(kind)
	return ENEMIES[kind] or ENEMIES.Forager
end

local function makeEnemyPart(kind, position)
	local model = AssetLoader.CloneEnemy(kind, position)
	if model then
		return model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	end

	local p = Instance.new("Part")
	p.Name = "Enemy_" .. kind
	p.Size = kind == "Miniboss" and Vector3.new(4, 6, 4) or Vector3.new(2, 3, 2)
	p.Material = Enum.Material.SmoothPlastic
	p.Color = KIND_COLOR[kind] or KIND_COLOR.Forager
	p.Position = position + Vector3.new(0, p.Size.Y / 2, 0)
	p.Anchored = false
	p.CanCollide = true
	p:SetAttribute("EnemyKind", kind)
	p.Parent = workspace
	return p
end

local function capReached()
	local tuningCap = (Tuning.get().Wave and Tuning.get().Wave.cap) or Tuning.get().waveCap or C.MaxNPCs
	return active >= C.MaxNPCs or active >= tuningCap
end

local function spawnOne(kind, position)
	if capReached() then return nil end
	local world = WorldRegistry.get()
	if not world then return nil end

	local profile = profileFor(kind)
	local part = makeEnemyPart(kind, position)
	active += 1
	part.Destroying:Connect(function()
		active = math.max(0, active - 1)
	end)

	local speed = profile.speed
	if OmenService.Is("BloodMoon") then
		local omen = (Tuning.get().Omen and Tuning.get().Omen.BloodMoon) or { speedMult = 1.15 }
		speed = math.floor(speed * (omen.speedMult or 1.15))
	end

	local comps = {
		EnemyType({ kind = kind, speed = speed }),
		InstanceRef({ inst = part }),
		AIState({ state = profile.state or "Probe" }),
		Health({ hp = profile.hp, max = profile.hp }),
		Target({ target = nil }),
		PathComp({ points = {}, i = 1, rethink = 0 }),
		Motion({ speed = speed }),
		Attack({ damage = profile.damage, radius = profile.range or profile.radius, cooldown = profile.cooldown }),
		Loot({ shards = profile.shards or 1 }),
	}
	if profile.boss then
		table.insert(comps, Boss({ stompMax = 7 }))
	end

	return world:spawn(table.unpack(comps))
end

function M.spawn(plan)
	if not plan or not plan.squads then return 0 end
	local spawned = 0
	for _, squad in ipairs(plan.squads) do
		for _ = 1, squad.count do
			if capReached() then return spawned end
			local cf = SpawnPoints.GetSpawnForKind(squad.type)
			if spawnOne(squad.type, cf.Position) then
				spawned += 1
			end
		end
	end
	return spawned
end

function M.GetActiveCount()
	return active
end

function M.GetEnemyProfile(kind)
	local source = profileFor(kind)
	return table.clone(source)
end

return M
