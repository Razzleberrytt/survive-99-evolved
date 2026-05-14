-- Shared constants for Survive 99: Evolved.
-- Keep this module small and generic; detailed tuning belongs in Shared/Config modules.

local Constants = {}

Constants.VERSION = "0.1.0-foundation"

Constants.PHASES = {
	LOBBY = "Lobby",
	DAY = "Day",
	DUSK = "Dusk",
	NIGHT = "Night",
	BOSS = "Boss",
	ESCAPE = "Escape",
	RESULTS = "Results",
}

Constants.REMOTES = {
	REQUEST_ROLE = "RequestRole",
	REQUEST_BUILD = "RequestBuild",
	REQUEST_REPAIR = "RequestRepair",
	REQUEST_INTERACT = "RequestInteract",
	REQUEST_ATTACK = "RequestAttack",
	REQUEST_REVIVE = "RequestRevive",
	REQUEST_CONSUME = "RequestConsume",
	REQUEST_PURCHASE = "RequestPurchase",
	STATE_PHASE_CHANGED = "StatePhaseChanged",
	STATE_PLAYER_STATS = "StatePlayerStats",
	STATE_BEACON = "StateBeacon",
	STATE_INVENTORY = "StateInventory",
	STATE_WAVE = "StateWave",
	UX_NOTIFICATION = "UxNotification",
}

Constants.DEFAULT_PLAYER_STATS = {
	maxHealth = 100,
	walkSpeed = 16,
	stamina = 100,
	carryCapacity = 10,
	reviveSeconds = 4,
	downSeconds = 30,
}

Constants.DEFAULT_BEACON_STATS = {
	maxHealth = 2000,
	startingHealth = 2000,
	maxFuel = 100,
	startingFuel = 50,
	lightRadius = 70,
	fuelDrainPerNight = 10,
	repairHealthPerResource = 50,
}

Constants.TUNING = {
	maxPlayers = 12,
	campaignNights = 99,
	daySeconds = 240,
	duskSeconds = 30,
	nightSeconds = 210,
	bossIntroSeconds = 8,
	interactRange = 12,
	buildGridSize = 4,
	maxPlaceablesPerRun = 120,
	maxActiveEnemies = 80,
	autosaveSeconds = 60,
	mobileMinButtonSize = 44,
}

Constants.SPAWN_RINGS = {
	Near = { min = 60, max = 90 },
	Mid = { min = 90, max = 150 },
	Far = { min = 150, max = 220 },
}

function Constants.waveBudget(night: number, players: number): number
	local safeNight = math.clamp(math.floor(night), 1, Constants.TUNING.campaignNights)
	local safePlayers = math.clamp(math.floor(players), 1, Constants.TUNING.maxPlayers)
	local base = 16 + 6 * safeNight + 1.1 * (safeNight ^ 1.35)
	local playerBoost = 8 * math.clamp(safePlayers - 4, 0, 8)

	return math.min(480, math.floor(base + playerBoost))
end

-- Backward-compatible aliases for older scripts while new code migrates to the
-- uppercase tables above. Keep these values synchronized during cleanup PRs.
Constants.MaxPlayers = Constants.TUNING.maxPlayers
Constants.MaxNPCs = Constants.TUNING.maxActiveEnemies
Constants.MaxPlaceables = Constants.TUNING.maxPlaceablesPerRun
Constants.MaxTraps = 40
Constants.SpawnRings = {
	Near = { Constants.SPAWN_RINGS.Near.min, Constants.SPAWN_RINGS.Near.max },
	Mid = { Constants.SPAWN_RINGS.Mid.min, Constants.SPAWN_RINGS.Mid.max },
	Far = { Constants.SPAWN_RINGS.Far.min, Constants.SPAWN_RINGS.Far.max },
}
Constants.OmenChances = {
	Fog = 0.15,
	Storm = 0.1,
	Eclipse = 0.08,
	BloodMoon = 0.06,
	Frost = 0.07,
	Wildfire = 0.05,
}
Constants.Beacon = {
	FuelDrainPerNight = Constants.DEFAULT_BEACON_STATS.fuelDrainPerNight,
	HeatRecoveryPerDay = 6,
	LightWeakenMin = 0.85,
}

function Constants.WaveBudget(night: number, players: number): number
	return Constants.waveBudget(night, players)
end

return Constants
