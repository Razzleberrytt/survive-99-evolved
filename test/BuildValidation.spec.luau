return function()
	describe("Grid snapping math", function()
		it("snaps to 2-stud grid", function()
			local function snap(x)
				return math.round(x / 2) * 2
			end
			expect(snap(3)).to.equal(4)
		end)
	end)
end
