local C = {}
C.MaxPlayers = 12
C.MaxNPCs = 80
C.MaxPlaceables = 120
C.MaxTraps = 40
C.SpawnRings = { Near = {60,90}, Mid = {90,150}, Far = {150,220} }
-- Aggressive curve
function C.WaveBudget(night, players)
	local base = 16 + 6 * night + 1.1 * (night ^ 1.35)
	local playerBoost = 8 * math.clamp(players - 4, 0, 8)
	return math.min(480, math.floor(base + playerBoost))
end
C.OmenChances = { Fog=0.15, Storm=0.10, Eclipse=0.08, Aurora=0.07, Quake=0.06 }
C.Beacon = {
	FuelDrainPerNight = 10,
	HeatRecoveryPerDay = 6,
	LightWeakenMin = 0.85, -- inside aura multiplier
}
return C
