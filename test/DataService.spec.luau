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

                it("tracks codex flags", function()
                        Data.LoadProfileAsync(fake)
                        Data.MarkCodexSeen(fake, "intro")
                        Data.MarkCodexCompleted(fake, "intro")
                        local snap = Data.GetProfileSnapshot(fake)
                        assert(snap.codex.seen.intro == true, "seen flag stored")
                        assert(snap.codex.completed.intro == true, "completed flag stored")
                end)
        end)
end
