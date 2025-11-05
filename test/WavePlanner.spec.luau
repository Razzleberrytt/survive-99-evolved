return function()
	local Planner = require(game.ReplicatedStorage.Shared.WavePlanner)

	describe("Wave budget ramps", function()
		it("grows by night and players", function()
			local b1 = Planner(1, 1).budget
			local b5 = Planner(5, 1).budget
			expect(b5).to.be.greaterThan(b1)
			local b5p = Planner(5, 8).budget
			expect(b5p).to.be.greaterThan(b5)
		end)
	end)
end
