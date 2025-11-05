return function()
	local Planner = require(game.ReplicatedStorage.Shared.WavePlanner)
	describe("Wave budget ramps", function()
		it("grows by night and players", function()
			local b1 = Planner(1, 1).budget
			local b5 = Planner(5, 1).budget
			assert(b5 > b1, "budget should grow by night")
			local b5p = Planner(5, 8).budget
			assert(b5p > b5, "budget should grow by players")
		end)
	end)
end
