return function()
  describe("RateLimiter", function()
    it("limits after burst", function()
      local mk = require(game.ServerScriptService.Net.RateLimiter)
      local allow = mk(2, 0)
      local fakePlayer = { UserId = 123 }

      expect(allow(fakePlayer :: any)).to.equal(true)
      expect(allow(fakePlayer :: any)).to.equal(true)
      expect(allow(fakePlayer :: any)).to.equal(false)
    end)
  end)

  describe("Validators", function()
    it("validates shape", function()
      local V = require(game.ReplicatedStorage.Shared.Net.Validators)
      local pass = V.shape({ x = V.number, name = V.string })

      expect(pass({ x = 1, name = "ok" })).to.equal(true)
      expect(pass({ x = "nope", name = "ok" })).to.equal(false)
    end)
  end)
end
