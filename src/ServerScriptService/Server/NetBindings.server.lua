local Rep = game:GetService("ReplicatedStorage")

local Remotes = require(game.ServerScriptService.Net.Remotes)
local Net = require(Rep.Remotes.Net)
local Validators = require(Rep.Shared.Net.Validators)
local AdminGuard = require(game.ServerScriptService.Security.AdminGuard)
local Throttle = require(script.Parent.Throttle)
local LiveConfigAdmin = require(game.ServerScriptService.Services.LiveConfigAdmin)
local AISpawner = require(game.ServerScriptService.Services.AISpawnerService)
local BuildService = require(game.ServerScriptService.Services.BuildService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local DataService = require(game.ServerScriptService.Services.DataService)
local SettingsService = require(game.ServerScriptService.Services.SettingsService)
local StoreService = require(game.ServerScriptService.Services.StoreService)
local Analytics = require(game.ServerScriptService.Services.AnalyticsAdapter)
local TutorialService = require(game.ServerScriptService.Services.TutorialService)
local GameService = require(game.ServerScriptService.Services.GameService)
local RescueService = require(game.ServerScriptService.Services.RescueService)
local Cosmetics = require(game.ServerScriptService.Services.CosmeticsService)
local CodexService = require(game.ServerScriptService.Services.CodexService)

local function throttleDenied()
	return false, "throttled"
end

Remotes.registerEvent(
	"NightStartVote",
	function(payload)
		return payload == nil or Validators.table(payload)
	end,
	function(player)
		GameService.requestNightStart(player)
	end,
	{ capacity = 3, refill = 0.5 }
)

Remotes.registerFunction(
	"PlaceRequest",
	Validators.shape({
		placeType = Validators.string,
		position = Validators.Vector3,
	}),
	function(player, payload)
		if not Throttle.consume(player, "build", 1) then
			return throttleDenied()
		end
		local cf = CFrame.new(payload.position)
		local ok, reason, snapped = BuildService.ValidatePlacement(player, payload.placeType, cf)
		if not ok then
			return false, reason
		end
		local placedId = BuildService.Place(player, payload.placeType, snapped)
		if not placedId then
			return false, "place_failed"
		end
		return true, placedId
	end,
	{ capacity = 10, refill = 2, onRateLimit = throttleDenied }
)

Remotes.registerFunction(
	"RepairRequest",
	Validators.shape({
		targetId = Validators.union(Validators.string, Validators.integer),
		amount = Validators.optional(Validators.number),
	}),
	function(player, payload)
		if not Throttle.consume(player, "repair", 1) then
			return throttleDenied()
		end
		local repaired = BuildService.Repair(player, payload.targetId, payload.amount)
		return true, repaired
	end,
	{ capacity = 8, refill = 1.5, onRateLimit = throttleDenied }
)

Remotes.registerFunction(
	"FuelBeacon",
	Validators.shape({
		amount = Validators.optional(Validators.number),
	}),
	function(player, payload)
		if not Throttle.consume(player, "fuel", 1) then
			return throttleDenied()
		end
		local amount = payload.amount or 5
		local result = BeaconService.ApplyFuel(amount)
		pcall(function()
			TutorialService.OnAction(player, "fuel")
		end)
		return true, result
	end,
	{ capacity = 6, refill = 1, onRateLimit = throttleDenied }
)

Remotes.registerFunction(
	"RescueInteract",
	Validators.shape({
		id = Validators.string,
		action = Validators.string,
	}),
	function(player, payload)
		local ok, result = pcall(function()
			return RescueService.Interact(player, payload.id, payload.action)
		end)
		if not ok then
			warn("[RescueInteract] handler error", result)
			return false, "handler_error"
		end
		return result
	end,
	{ capacity = 5, refill = 1 }
)

Remotes.registerFunction(
	"GetProfile",
	function(payload)
		return payload == nil or Validators.table(payload)
	end,
	function(player, _payload)
		return DataService.GetProfileSnapshot(player)
	end,
	{ capacity = 4, refill = 0.5 }
)

Net.ListCosmetics.OnServerInvoke = function(player)
	return Cosmetics.GetShop(player)
end

Net.BuyCosmetic.OnServerInvoke = function(player, id)
	local ok, why = Cosmetics.Buy(player, id)
	return ok, why
end

Net.EquipCosmetic.OnServerInvoke = function(player, id)
	local ok, why = Cosmetics.Equip(player, id)
	return ok, why
end

Remotes.registerFunction(
	"PerfPing",
	Validators.shape({ tClient = Validators.number }),
	function(_player, _payload)
		return os.clock()
	end,
	{ capacity = 10, refill = 2 }
)

Remotes.registerFunction(
	"ToggleSetting",
	Validators.shape({
		category = Validators.string,
		key = Validators.string,
		value = Validators.optional(Validators.any),
	}),
	function(player, payload)
		return SettingsService.Toggle(player, payload.category, payload.key, payload.value)
	end,
	{ capacity = 6, refill = 1 }
)

Remotes.registerFunction(
	"PurchaseProduct",
	Validators.shape({ productKey = Validators.string }),
        function(player, payload)
                Analytics.PurchaseAttempt(player, payload.productKey)
                local policy = StoreService.CanOffer(player)
                if not policy.allowIAP then
                        Analytics.PurchaseResult(player, payload.productKey, false)
                        CodexService.Emit("PURCHASE_RESULT", { player = player, playerUserId = player.UserId, key = payload.productKey, ok = false })
                        return false, "iap_blocked"
                end
                local ok, err = StoreService.PurchaseDevProduct(player, payload.productKey)
                Analytics.PurchaseResult(player, payload.productKey, ok == true)
                CodexService.Emit("PURCHASE_RESULT", { player = player, playerUserId = player.UserId, key = payload.productKey, ok = ok == true })
                return ok, err
        end,
	{ capacity = 4, refill = 0.5 }
)

local function adminDenied()
	return false, "not_admin"
end

Remotes.registerFunction(
	"AdminAction",
	Validators.shape({
		action = Validators.string,
		payload = Validators.optional(Validators.table),
	}),
	function(player, payload)
		local action = payload.action
		local actionPayload = payload.payload or {}
		if action == "_probe" then
			return true
		elseif action == "spawn_miniboss" then
			AISpawner.spawn({ budget = 1, squads = { { type = "Miniboss", count = 1 } } })
			return true
		elseif action == "spawn_wave" then
			AISpawner.spawn({ budget = 99, squads = { { type = "Forager", count = 6 }, { type = "Bruiser", count = 3 } } })
			return true
		elseif action == "fuel_plus" then
			BeaconService.ApplyFuel(20)
			return true
		elseif action == "blackout" then
			BeaconService.ApplyFuel(-200)
			return true
		elseif action == "give_shards" then
			local amount = 50
			if type(actionPayload.amount) == "number" then
				amount = math.clamp(actionPayload.amount, 0, 10_000)
			end
			DataService.AddShards(player, amount)
			return true
		elseif action == "reset_tutorial" then
			local profile = DataService.GetProfileSnapshot(player) or DataService.LoadProfileAsync(player)
			if profile then
				profile.tutorialComplete = nil
			end
			TutorialService.Begin(player)
			return true
		end
		return false, "unknown_action"
	end,
	{ permission = AdminGuard, onDenied = adminDenied, capacity = 4, refill = 0.5 }
)

Remotes.registerFunction(
	"AdminSetConfig",
	Validators.shape({
		kind = Validators.string,
		key = Validators.string,
		value = Validators.optional(Validators.any),
	}),
	function(player, payload)
		if payload.kind == "flag" then
			return LiveConfigAdmin.SetFlag(player.UserId, payload.key, payload.value)
		elseif payload.kind == "tuning" then
			return LiveConfigAdmin.SetTuning(player.UserId, payload.key, payload.value)
		end
		return false, "bad_kind"
	end,
	{ permission = AdminGuard, onDenied = adminDenied, capacity = 3, refill = 0.5 }
)
