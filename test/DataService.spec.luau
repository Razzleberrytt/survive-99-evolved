return function()
	local Data = require(game.ServerScriptService.Services.DataService)
	local fake = { UserId = 123 }
	describe("DataService basic ops", function()
		it("loads and adds shards", function()
			local p = Data.LoadProfileAsync(fake)
			local before = p.currencies.shards
			Data.AddShards(fake, 5)
			assert(p.currencies.shards == before + 5, "shards should increase")
		end)
	end)
end
