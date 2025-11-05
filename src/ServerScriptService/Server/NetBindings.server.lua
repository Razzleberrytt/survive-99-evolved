local Rep = game:GetService("ReplicatedStorage")

local Remotes = require(game.ServerScriptService.Net.Remotes)
local Validators = require(Rep.Shared.Net.Validators)
local Throttle = require(script.Parent.Throttle)
local BuildService = require(game.ServerScriptService.Services.BuildService)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)
local DataService = require(game.ServerScriptService.Services.DataService)
local SettingsService = require(game.ServerScriptService.Services.SettingsService)
local StoreService = require(game.ServerScriptService.Services.StoreService)
local Analytics = require(game.ServerScriptService.Services.AnalyticsAdapter)
local TutorialService = require(game.ServerScriptService.Services.TutorialService)
local GameService = require(game.ServerScriptService.Services.GameService)
local RescueService = require(game.ServerScriptService.Services.RescueService)

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
			return false, "iap_blocked"
		end
		local ok, err = StoreService.PurchaseDevProduct(player, payload.productKey)
		Analytics.PurchaseResult(player, payload.productKey, ok == true)
		return ok, err
	end,
	{ capacity = 4, refill = 0.5 }
)

