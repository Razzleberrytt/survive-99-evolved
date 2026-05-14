local Players = game:GetService("Players")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local GameConfig = require(Rep.Shared.Config.Game)

local M = {}

local SurvivalConfig = GameConfig.Survival

local DEFAULT = {
	health = SurvivalConfig.MaxHealth,
	maxHealth = SurvivalConfig.MaxHealth,
	hunger = 100,
	thirst = 100,
	stamina = SurvivalConfig.MaxStamina,
	maxStamina = SurvivalConfig.MaxStamina,
	xp = 0,
	level = 1,
}

local stats = {}
local running = false

local function cloneDefaults()
	return table.clone(DEFAULT)
end

local function getHumanoid(player)
	local character = player.Character
	return character and character:FindFirstChildOfClass("Humanoid")
end

local function syncHealth(player, state)
	local humanoid = getHumanoid(player)
	if not humanoid then return end
	humanoid.MaxHealth = state.maxHealth
	humanoid.Health = math.clamp(state.health, 0, state.maxHealth)
end

local function push(player)
	local state = stats[player]
	if state then
		Net.SurvivalChanged:FireClient(player, table.clone(state))
	end
end

local function ensure(player)
	local state = stats[player]
	if not state then
		state = cloneDefaults()
		stats[player] = state
	end
	return state
end

local function awardXp(player, amount)
	local state = ensure(player)
	state.xp += amount
	local needed = 50 + state.level * 25
	while state.xp >= needed do
		state.xp -= needed
		state.level += 1
		state.maxHealth += 10
		state.maxStamina += 8
		state.health = state.maxHealth
		state.stamina = state.maxStamina
		needed = 50 + state.level * 25
	end
	push(player)
end

function M.Get(player)
	return ensure(player)
end

function M.ConsumeStamina(player, amount)
	local state = ensure(player)
	if state.stamina < amount then
		push(player)
		return false
	end
	state.stamina -= amount
	push(player)
	return true
end

function M.Damage(player, amount, source)
	local state = ensure(player)
	state.health = math.max(0, state.health - amount)
	syncHealth(player, state)
	push(player)
	if state.health <= 0 then
		local humanoid = getHumanoid(player)
		if humanoid then humanoid.Health = 0 end
	end
	return state.health, source
end

function M.Heal(player, amount)
	local state = ensure(player)
	state.health = math.min(state.maxHealth, state.health + amount)
	syncHealth(player, state)
	push(player)
	return state.health
end

function M.Feed(player, hunger, thirst)
	local state = ensure(player)
	state.hunger = math.min(100, state.hunger + (hunger or 0))
	state.thirst = math.min(100, state.thirst + (thirst or 0))
	push(player)
	return state
end

function M.AwardKill(player, enemyKind)
	local enemy = GameConfig.Enemies[enemyKind] or GameConfig.Enemies.Forager
	awardXp(player, enemy.xp or 5)
	M.Feed(player, enemyKind == "Sapper" and 6 or 1, enemyKind == "Screecher" and 4 or 1)
end

local function tickPlayer(player, dt)
	local state = ensure(player)
	state.hunger = math.max(0, state.hunger - SurvivalConfig.HungerDrain * dt)
	state.thirst = math.max(0, state.thirst - SurvivalConfig.ThirstDrain * dt)
	state.stamina = math.min(state.maxStamina, state.stamina + SurvivalConfig.StaminaRegen * dt)

	if state.hunger <= 0 or state.thirst <= 0 then
		M.Damage(player, SurvivalConfig.StarveDamage * dt, "survival")
	elseif state.health < state.maxHealth and state.hunger > SurvivalConfig.RegenNeed and state.thirst > SurvivalConfig.RegenNeed then
		state.health = math.min(state.maxHealth, state.health + SurvivalConfig.RegenHealth * dt)
		syncHealth(player, state)
	end
end

function M.Start()
	if running then return end
	running = true
	Players.PlayerAdded:Connect(function(player)
		ensure(player)
		player.CharacterAdded:Connect(function()
			task.wait(0.2)
			syncHealth(player, ensure(player))
			push(player)
		end)
		push(player)
	end)
	Players.PlayerRemoving:Connect(function(player)
		stats[player] = nil
	end)
	for _, player in ipairs(Players:GetPlayers()) do
		ensure(player)
		push(player)
	end
	task.spawn(function()
		while running do
			local dt = task.wait(1)
			for _, player in ipairs(Players:GetPlayers()) do
				tickPlayer(player, dt)
				push(player)
			end
		end
	end)
end

return M
