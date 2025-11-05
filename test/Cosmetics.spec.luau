return function()
	local Catalog = require(game.ReplicatedStorage.Shared.Config.Cosmetics)
	describe("Cosmetics Catalog", function()
		it("has items and daily count", function()
			assert(Catalog.Items and next(Catalog.Items) ~= nil, "no items")
			assert(type(Catalog.DailyCount) == "number", "no daily count")
		end)
	end)
end
