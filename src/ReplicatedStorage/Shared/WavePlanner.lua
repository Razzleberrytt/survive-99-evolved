local Constants = require(script.Parent.Constants)

local WeightsByNight = {
	Forager = 4,
	Bruiser = 2,
	Swarmling = 3,
	Screecher = 1,
	Sapper = 0.5,
}

local function plan(night: number, players: number)
	local budget = Constants.WaveBudget(night, players)
	local pool = budget
	local squads = {}

	local function add(enemyType: string, cost: number, size: number?)
		if pool <= 0 then
			return
		end
		local defaultCount = math.max(1, math.floor((WeightsByNight[enemyType] or 1)))
		table.insert(squads, {
			type = enemyType,
			count = size or defaultCount,
		})
		pool -= cost
	end

	add("Forager", 8, 4)
	add("Swarmling", 10, 6)
	if night >= 3 then
		add("Bruiser", 14, 3)
	end
	if night >= 4 then
		add("Screecher", 12, 2)
	end
	if night >= 6 then
		add("Sapper", 18, 1)
	end

	return {
		budget = budget,
		squads = squads,
	}
end

return plan
