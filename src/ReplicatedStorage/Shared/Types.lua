local Types = {}

export type BeaconState = {
	fuel: number,
	heat: number,
	lightRadius: number,
	stability: number,
}

export type SquadOrder = {
	type: "Probe" | "Flank" | "FocusBeacon" | "Retreat",
	target: Vector3?,
}

export type WavePlan = {
	budget: number,
	squads: { { type: string, count: number } },
}

return Types
