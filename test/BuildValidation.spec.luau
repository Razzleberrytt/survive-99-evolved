return function()
	describe("Grid snapping", function()
		it("snaps to 2-stud grid", function()
			local function snap(x) return math.round(x / 2) * 2 end
			assert(snap(3) == 4, "3 should snap to 4")
		end)
	end)
end
