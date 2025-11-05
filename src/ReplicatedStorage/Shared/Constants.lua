local Constants = {}

Constants.MaxPlayers = 12
Constants.MaxNPCs = 80
Constants.MaxPlaceables = 120
Constants.MaxTraps = 40

Constants.SpawnRings = {
	Near = { 60, 90 },
	Mid = { 90, 150 },
	Far = { 150, 220 },
}

function Constants.WaveBudget(night: number, players: number): number
	local base = 16 + 6 * night + 1.1 * (night ^ 1.35)
	local playerBoost = 8 * math.clamp(players - 4, 0, 8)
	return math.min(480, math.floor(base + playerBoost))
end

Constants.OmenChances = {
	Fog = 0.15,
	Storm = 0.10,
	Eclipse = 0.08,
	Aurora = 0.07,
	Quake = 0.06,
}

return Constants
