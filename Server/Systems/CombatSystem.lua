local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage.Shared.Config.Game)

local lastSwing = {}

local function root(player)
	local character = player.Character
	return character and character.PrimaryPart
end

local function weapon(id)
	return GameConfig.Weapons[id] or GameConfig.Weapons.melee
end

local function nearestEnemy(player, cfg)
	local r = root(player)
	if not r then return nil end
	local best, bestDist
	for _, inst in ipairs(workspace:GetChildren()) do
		if inst:IsA("BasePart") and inst.Name:match("^Enemy_") and (inst:GetAttribute("HP") or 0) > 0 then
			local dist = (inst.Position - r.Position).Magnitude
			if dist <= cfg.range and (not bestDist or dist < bestDist) then
				best, bestDist = inst, dist
			end
		end
	end
	return best
end

local function attack(player, weaponId)
	local cfg = weapon(weaponId)
	local now = os.clock()
	lastSwing[player] = lastSwing[player] or {}
	if now < (lastSwing[player][weaponId] or 0) then return false, "cooldown" end
	lastSwing[player][weaponId] = now + cfg.cooldown

	local enemy = nearestEnemy(player, cfg)
	if not enemy then return true, "miss" end
	local hp = math.max(0, (enemy:GetAttribute("HP") or 1) - cfg.damage)
	enemy:SetAttribute("HP", hp)
	if hp <= 0 then enemy:Destroy() end
	return true, "hit"
end

Players.PlayerRemoving:Connect(function(player)
	lastSwing[player] = nil
end)

local system = function(_world)
	-- Kept as a lightweight system hook; attacks are applied through system.Attack.
end

system.Attack = attack
return system
