return function()
    local CodexService = require(game.ServerScriptService.Services.CodexService)
    local Players = game:GetService("Players")

    local player = Instance.new("Player")
    player.UserId = 98765
    player.Name = "CodexTester"
    player.Parent = Players

    describe("CodexService gates", function()
        it("evaluates beacon fuel thresholds", function()
            local session = { shown = {}, cooldowns = {}, active = {} }
            local ctx = {
                world = { camp = { beaconFuel = 80, structures = {} }, day = 1 },
                player = player,
                profile = { codex = { seen = {}, completed = {} }, settings = { accessibility = { reduceFlashes = false } } },
                session = session,
            }
            local prompt = { id = "fuel", gates = { { type = "BeaconFuelBelow", value = 60 } } }
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(false)
            ctx.world.camp.beaconFuel = 40
            session.shown = {}
            session.cooldowns = {}
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(true)
        end)

        it("respects once per session", function()
            local session = { shown = {}, cooldowns = {}, active = {} }
            local ctx = {
                world = { camp = { beaconFuel = 10, structures = {} }, day = 1 },
                player = player,
                profile = { codex = { seen = {}, completed = {} }, settings = {} },
                session = session,
            }
            local prompt = { id = "session", gates = { { type = "OncePerSession" } } }
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(true)
            session.shown.session = true
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(false)
        end)

        it("checks profile settings", function()
            local session = { shown = {}, cooldowns = {}, active = {} }
            local ctx = {
                world = { camp = { beaconFuel = 10, structures = {} }, day = 1 },
                player = player,
                profile = { codex = { seen = {}, completed = {} }, settings = { accessibility = { reduceFlashes = false } } },
                session = session,
            }
            local prompt = {
                id = "access",
                gates = { { type = "ProfileSettingEquals", category = "accessibility", key = "reduceFlashes", value = false } },
            }
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(true)
            ctx.profile.settings.accessibility.reduceFlashes = true
            expect(CodexService._test.canShow(ctx, prompt)).to.equal(false)
        end)
    end)
end
