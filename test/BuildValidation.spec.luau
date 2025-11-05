return function()
	describe("Grid snapping math", function()
		it("snaps to 2-stud grid", function()
			local function snap(x) return math.round(x / 2) * 2 end
			assert(snap(3) == 4, "3->4")
			assert(snap(2.9) == 2, "2.9->2")
		end)
	end)
end
