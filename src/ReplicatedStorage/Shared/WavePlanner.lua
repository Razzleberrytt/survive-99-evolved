local C = require(script.Parent.Constants)

local COST = {
	Swarmling = 4,
	Forager = 6,
	Screecher = 10,
	Bruiser = 14,
	Sapper = 16,
	Miniboss = 60,
}

local function add(squads, kind, count)
	if count and count > 0 then
		table.insert(squads, { type = kind, count = count })
	end
end

local function spend(budget, squads, kind, desired)
	local cost = COST[kind] or COST.Forager
	local count = math.max(0, math.min(desired, math.floor(budget / cost)))
	add(squads, kind, count)
	return budget - count * cost
end

return function(night, players, omen)
	local budget = C.WaveBudget(night, players)
	local squads = {}
	local remaining = budget

	remaining = spend(remaining, squads, "Swarmling", 4 + night + players)
	remaining = spend(remaining, squads, "Forager", 3 + math.floor(night * 1.4))
	if night >= 2 then remaining = spend(remaining, squads, "Bruiser", 1 + math.floor(night / 2)) end
	if night >= 3 then remaining = spend(remaining, squads, "Screecher", 1 + math.floor(night / 3)) end
	if night >= 5 then remaining = spend(remaining, squads, "Sapper", math.floor(night / 4)) end

	if omen == "Storm" then
		remaining = spend(remaining, squads, "Bruiser", 2)
	elseif omen == "Eclipse" then
		remaining = spend(remaining, squads, "Screecher", 3)
	elseif omen == "Fog" then
		remaining = spend(remaining, squads, "Swarmling", 5)
	end

	if night % 5 == 0 and remaining >= COST.Miniboss then
		remaining = spend(remaining, squads, "Miniboss", 1)
	end

	return { budget = budget, squads = squads, omen = omen, unspent = remaining }
end
