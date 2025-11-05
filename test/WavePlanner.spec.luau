return function()
	local Planner = require(game.ReplicatedStorage.Shared.WavePlanner)
	describe("Wave budget and omen", function()
		it("grows with night and accepts omen", function()
			local p1 = Planner(1, 1, nil)
			local p5 = Planner(5, 1, "Storm")
			assert(p5.budget > p1.budget, "budget should grow")
			local hasBruiser = false
			for _, s in ipairs(p5.squads) do if s.type=="Bruiser" then hasBruiser = true end end
			assert(hasBruiser, "storm should bias bruisers")
		end)
	end)
end
