local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage.Shared.Config.Game)

local function budgetFor(night)
	local base = GameConfig.Wave.BaseBudget[night] or (100 + night * 18)
	return math.floor(base * (1 + math.max(#Players:GetPlayers() - 1, 0) * GameConfig.Wave.TeamFactor))
end

local function spend(plan, kind, wanted)
	local cost = GameConfig.Wave.EnemyCosts[kind] or 6
	local count = math.max(0, math.min(wanted, math.floor(plan.remaining / cost)))
	if count > 0 then
		table.insert(plan.squads, { type = kind, count = count })
		plan.remaining -= count * cost
	end
end

local function buildPlan(night, omen)
	local plan = { night = night, omen = omen, budget = budgetFor(night), remaining = budgetFor(night), squads = {} }
	spend(plan, "Swarmling", 4 + night)
	spend(plan, "Forager", 3 + math.floor(night * 1.3))
	if night >= 2 then spend(plan, "Bruiser", 1 + math.floor(night / 2)) end
	if night >= 3 then spend(plan, "Screecher", 1 + math.floor(night / 3)) end
	if night >= 5 then spend(plan, "Sapper", math.floor(night / 4)) end
	if night % 5 == 0 then spend(plan, "Miniboss", 1) end
	return plan
end

return function(_world, state)
	state = state or {}
	return buildPlan(state.night or 1, state.omen)
end
