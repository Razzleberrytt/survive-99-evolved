local C = require(script.Parent.Constants)
return function(night, players, omen)
	local budget = C.WaveBudget(night, players)
	local squads = {}
	local function add(type, count) table.insert(squads, {type = type, count = count}) end
	-- Base mix
	add("Forager", 4)
	add("Swarmling", 6)
	if night >= 3 then add("Bruiser", 3) end
	if night >= 4 then add("Screecher", 2) end
	if night >= 6 then add("Sapper", 1) end
	-- Omen influence
	if omen == "Storm" then add("Bruiser", 2) end
	if omen == "Eclipse" then add("Screecher", 2) end
	return { budget = budget, squads = squads, omen = omen }
end
