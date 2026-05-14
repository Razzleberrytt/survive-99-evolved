local Rep = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local WorldRegistry = require(Rep.Shared.WorldRegistry)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Health = require(Rep.Components.C_Health)
local EnemyType = require(Rep.Components.C_EnemyType)
local Net = require(Rep.Remotes.Net)
local GameConfig = require(Rep.Shared.Config.Game)
local SurvivalService = require(script.Parent.SurvivalService)

local M = {}
local cooldowns = {}

local AIM_ARC = {
	melee = 0.45,
	pistol = 0.12,
}

local function characterRoot(player)
	local character = player.Character
	return character and character.PrimaryPart
end

local function weaponFor(id)
	return GameConfig.Weapons[id] or GameConfig.Weapons.melee
end

local function canUse(player, weaponId)
	local now = os.clock()
	cooldowns[player] = cooldowns[player] or {}
	local readyAt = cooldowns[player][weaponId] or 0
	if now < readyAt then return false, "cooldown" end
	local weapon = weaponFor(weaponId)
	if not SurvivalService.ConsumeStamina(player, weapon.stamina or 0) then return false, "tired" end
	cooldowns[player][weaponId] = now + weapon.cooldown
	return true
end

local function closestEnemy(player, weapon, weaponId)
	local root = characterRoot(player)
	local world = WorldRegistry.get()
	if not root or not world then return nil end
	local look = root.CFrame.LookVector
	local best
	for id, ref, hp, enemy in world:query(InstanceRef, Health, EnemyType) do
		local inst = ref.inst
		if inst and inst.Parent and hp.hp > 0 then
			local delta = inst.Position - root.Position
			local dist = delta.Magnitude
			if dist <= weapon.range then
				local facing = dist < 2 and 1 or look:Dot(delta.Unit)
				if facing >= (AIM_ARC[weaponId] or weapon.arc or 0.35) and (not best or dist < best.dist) then
					best = { id = id, hp = hp, ref = ref, enemy = enemy, dist = dist }
				end
			end
		end
	end
	return best
end

function M.Attack(player, payload)
	local weaponId = (payload and payload.weaponId) or "melee"
	local weapon = weaponFor(weaponId)
	local ok, reason = canUse(player, weaponId)
	if not ok then return false, reason end

	local hit = closestEnemy(player, weapon, weaponId)
	if not hit then return true, "miss" end
	hit.hp.hp = math.max(0, hit.hp.hp - weapon.damage)
	Net.SpawnVFX:FireAllClients({ kind = "damage", part = hit.ref.inst, amount = weapon.damage })
	Net.PlaySound:FireAllClients("hit")
	if hit.hp.hp <= 0 then
		SurvivalService.AwardKill(player, hit.enemy.kind)
	end
	return true, "hit", hit.enemy.kind, hit.hp.hp
end

function M.Fire(player, payload)
	local root = characterRoot(player)
	if not root then return false, "no_character" end
	local origin = payload and payload.origin or root.Position
	local dir = payload and payload.dir
	if typeof(dir) ~= "Vector3" or dir.Magnitude <= 0 then
		dir = root.CFrame.LookVector
	end
	local weapon = weaponFor("pistol")
	local ok, reason = canUse(player, "pistol")
	if not ok then return false, reason end

	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { player.Character }
	local result = Workspace:Raycast(origin, dir.Unit * weapon.range, params)
	if result and result.Instance then
		local world = WorldRegistry.get()
		if world then
			for id, ref, hp, enemy in world:query(InstanceRef, Health, EnemyType) do
				if ref.inst == result.Instance or result.Instance:IsDescendantOf(ref.inst) then
					hp.hp = math.max(0, hp.hp - weapon.damage)
					Net.SpawnVFX:FireAllClients({ kind = "damage", part = ref.inst, amount = weapon.damage })
					if hp.hp <= 0 then SurvivalService.AwardKill(player, enemy.kind) end
					return true, "hit", enemy.kind, hp.hp
				end
			end
		end
	end
	return true, "miss"
end

function M.Start()
	game:GetService("Players").PlayerRemoving:Connect(function(player)
		cooldowns[player] = nil
	end)
end

return M
