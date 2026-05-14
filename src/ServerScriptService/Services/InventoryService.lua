local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Constants = require(ReplicatedStorage.Shared.Constants)
local Resources = require(ReplicatedStorage.Shared.Config.Resources)
local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)
local RemoteService = require(script.Parent.RemoteService)

local InventoryService = {}

local DEPOSITABLE_RESOURCES = {
	Wood = true,
	Scrap = true,
	Food = true,
	Fuel = true,
	Essence = true,
}

local STARTER_RESOURCES = {
	Wood = 15,
	Scrap = 5,
	Food = 2,
	Fuel = 1,
}

local initialized = false
local personalInventories: { [Player]: { [string]: number } } = {}
local playersGrantedStarterResources: { [Player]: boolean } = {}
local teamInventory: { [string]: number } = {}

local function isFiniteNumber(value: any): boolean
	return typeof(value) == "number" and value == value and value < math.huge and value > -math.huge
end

local function toNonNegativeInteger(value: any): number?
	if not isFiniteNumber(value) or value < 0 then
		return nil
	end

	return math.floor(value)
end

local function toPositiveInteger(value: any): number?
	local amount = toNonNegativeInteger(value)
	if not amount or amount <= 0 then
		return nil
	end

	return amount
end

local function isValidResource(resourceType: any): boolean
	return typeof(resourceType) == "string" and typeof(Resources[resourceType]) == "table"
end

local function isDepositableResource(resourceType: string): boolean
	return DEPOSITABLE_RESOURCES[resourceType] == true
end

local function emptyInventory(includeShards: boolean?): { [string]: number }
	local inventory = {}
	for resourceType, resourceConfig in pairs(Resources) do
		if typeof(resourceConfig) == "table" and (includeShards or resourceType ~= "Shards") then
			inventory[resourceType] = 0
		end
	end
	return inventory
end

local function copyInventory(inventory: { [string]: number }): { [string]: number }
	local copy = {}
	for resourceType, resourceConfig in pairs(Resources) do
		if typeof(resourceConfig) == "table" and inventory[resourceType] ~= nil then
			copy[resourceType] = math.max(0, math.floor(inventory[resourceType]))
		end
	end
	return copy
end

local function getCarryCap(resourceType: string): number?
	local resourceConfig = Resources[resourceType]
	local cap = resourceConfig and resourceConfig.carryCap
	if not cap and resourceConfig and resourceConfig.stats then
		cap = resourceConfig.stats.baseCarry
	end

	local normalizedCap = toNonNegativeInteger(cap)
	return normalizedCap
end

local function ensurePersonalInventory(player: Player): { [string]: number }
	local inventory = personalInventories[player]
	if not inventory then
		inventory = emptyInventory(false)
		personalInventories[player] = inventory
	end
	return inventory
end

local function ensureTeamInventory()
	for resourceType, resourceConfig in pairs(Resources) do
		if typeof(resourceConfig) == "table" and resourceType ~= "Shards" and teamInventory[resourceType] == nil then
			teamInventory[resourceType] = 0
		end
	end
end

local function isPlayerAlive(player: Player): boolean
	local character = player.Character
	if not character then
		return true
	end

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return true
	end

	return humanoid.Health > 0
end

local function isNearBeacon(player: Player): boolean
	local beacon = workspace:FindFirstChild("Beacon")
	if not beacon then
		return true
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root or not root:IsA("BasePart") then
		return false
	end

	local beaconPosition: Vector3?
	if beacon:IsA("BasePart") then
		beaconPosition = beacon.Position
	elseif beacon:IsA("Model") then
		beaconPosition = beacon:GetPivot().Position
	end

	if not beaconPosition then
		return true
	end

	local depositRange = Constants.RESOURCE_DEPOSIT_RANGE or Constants.TUNING.interactRange
	return (root.Position - beaconPosition).Magnitude <= depositRange
end

local function getResourceStateEvent(): RemoteEvent?
	return RemoteService.GetEvent(RemoteNames.ResourceStateChanged)
end

function InventoryService.Init()
	if initialized then
		return
	end

	RemoteService.Init()
	ensureTeamInventory()

	local depositRequest = RemoteService.GetEvent(RemoteNames.RequestDepositResource)
	if depositRequest then
		depositRequest.OnServerEvent:Connect(function(player: Player, payload)
			InventoryService.HandleDepositRequest(player, payload)
		end)
	end

	initialized = true
end

function InventoryService.PlayerAdded(player: Player)
	ensurePersonalInventory(player)

	if playersGrantedStarterResources[player] then
		InventoryService.BroadcastState(player)
		return
	end

	playersGrantedStarterResources[player] = true
	if Constants.DEV_GRANT_STARTER_RESOURCES then
		for resourceType, amount in pairs(STARTER_RESOURCES) do
			InventoryService.AddPersonalResource(player, resourceType, amount, "DevStarterGrant")
		end
	else
		InventoryService.BroadcastState(player)
	end
end

function InventoryService.PlayerRemoving(player: Player)
	personalInventories[player] = nil
	playersGrantedStarterResources[player] = nil
end

function InventoryService.GetPersonalInventory(player: Player): { [string]: number }
	return copyInventory(ensurePersonalInventory(player))
end

function InventoryService.GetTeamInventory(): { [string]: number }
	ensureTeamInventory()
	return copyInventory(teamInventory)
end

function InventoryService.AddPersonalResource(player: Player, resourceType: string, amount: number, _source: any?): (boolean, any)
	if not player or not player:IsA("Player") then
		return false, "InvalidPlayer"
	end
	if not isValidResource(resourceType) or resourceType == "Shards" then
		return false, "InvalidResource"
	end

	local safeAmount = toPositiveInteger(amount)
	if not safeAmount then
		return false, "InvalidAmount"
	end

	local inventory = ensurePersonalInventory(player)
	local cap = getCarryCap(resourceType)
	local currentAmount = inventory[resourceType] or 0
	local newAmount = currentAmount + safeAmount
	if cap then
		newAmount = math.min(newAmount, cap)
	end
	inventory[resourceType] = math.max(0, math.floor(newAmount))

	InventoryService.BroadcastState(player)
	return true, InventoryService.GetPersonalInventory(player)
end

function InventoryService.RemovePersonalResource(player: Player, resourceType: string, amount: number, _reason: any?): (boolean, any)
	if not player or not player:IsA("Player") then
		return false, "InvalidPlayer"
	end
	if not isValidResource(resourceType) or resourceType == "Shards" then
		return false, "InvalidResource"
	end

	local safeAmount = toPositiveInteger(amount)
	if not safeAmount then
		return false, "InvalidAmount"
	end

	local inventory = ensurePersonalInventory(player)
	local currentAmount = inventory[resourceType] or 0
	if currentAmount < safeAmount then
		return false, "InsufficientPersonalResource"
	end

	inventory[resourceType] = math.max(0, currentAmount - safeAmount)
	InventoryService.BroadcastState(player)
	return true, InventoryService.GetPersonalInventory(player)
end

function InventoryService.AddTeamResource(resourceType: string, amount: number, _source: any?): (boolean, any)
	if not isValidResource(resourceType) or resourceType == "Shards" then
		return false, "InvalidResource"
	end

	local safeAmount = toPositiveInteger(amount)
	if not safeAmount then
		return false, "InvalidAmount"
	end

	ensureTeamInventory()
	teamInventory[resourceType] = math.max(0, math.floor((teamInventory[resourceType] or 0) + safeAmount))
	InventoryService.BroadcastState()
	return true, InventoryService.GetTeamInventory()
end

function InventoryService.RemoveTeamResource(resourceType: string, amount: number, _reason: any?): (boolean, any)
	if not isValidResource(resourceType) or resourceType == "Shards" then
		return false, "InvalidResource"
	end

	local safeAmount = toPositiveInteger(amount)
	if not safeAmount then
		return false, "InvalidAmount"
	end

	ensureTeamInventory()
	local currentAmount = teamInventory[resourceType] or 0
	if currentAmount < safeAmount then
		return false, "InsufficientTeamResource"
	end

	teamInventory[resourceType] = math.max(0, currentAmount - safeAmount)
	InventoryService.BroadcastState()
	return true, InventoryService.GetTeamInventory()
end

function InventoryService.DepositResource(player: Player, resourceType: string, amount: number?): (boolean, any)
	if not player or not player:IsA("Player") then
		return false, "InvalidPlayer"
	end
	if not personalInventories[player] then
		return false, "InventoryNotInitialized"
	end
	if not isValidResource(resourceType) or not isDepositableResource(resourceType) then
		return false, "InvalidResource"
	end
	if not isPlayerAlive(player) then
		return false, "PlayerNotAlive"
	end
	if not isNearBeacon(player) then
		return false, "TooFarFromBeacon"
	end

	local personal = ensurePersonalInventory(player)
	local carried = personal[resourceType] or 0
	if carried <= 0 then
		return false, "NoPersonalResource"
	end

	local requestedAmount = carried
	if amount ~= nil then
		local safeAmount = toPositiveInteger(amount)
		if not safeAmount then
			return false, "InvalidAmount"
		end
		requestedAmount = safeAmount
	end

	local transferAmount = math.min(carried, requestedAmount)
	personal[resourceType] = math.max(0, carried - transferAmount)
	teamInventory[resourceType] = math.max(0, math.floor((teamInventory[resourceType] or 0) + transferAmount))

	InventoryService.BroadcastState()
	return true, {
		resourceType = resourceType,
		amount = transferAmount,
		personal = InventoryService.GetPersonalInventory(player),
		team = InventoryService.GetTeamInventory(),
	}
end

function InventoryService.DepositAll(player: Player): (boolean, any)
	if not player or not player:IsA("Player") then
		return false, "InvalidPlayer"
	end
	if not personalInventories[player] then
		return false, "InventoryNotInitialized"
	end
	if not isPlayerAlive(player) then
		return false, "PlayerNotAlive"
	end
	if not isNearBeacon(player) then
		return false, "TooFarFromBeacon"
	end

	local personal = ensurePersonalInventory(player)
	local transferred = {}
	local totalTransferred = 0

	for resourceType in pairs(DEPOSITABLE_RESOURCES) do
		local carried = math.max(0, math.floor(personal[resourceType] or 0))
		if carried > 0 then
			personal[resourceType] = 0
			teamInventory[resourceType] = math.max(0, math.floor((teamInventory[resourceType] or 0) + carried))
			transferred[resourceType] = carried
			totalTransferred += carried
		end
	end

	if totalTransferred <= 0 then
		return false, "NoDepositableResources"
	end

	InventoryService.BroadcastState()
	return true, {
		transferred = transferred,
		personal = InventoryService.GetPersonalInventory(player),
		team = InventoryService.GetTeamInventory(),
	}
end

function InventoryService.GetPublicState(player: Player?): { [string]: any }
	local personal = nil
	if player then
		personal = InventoryService.GetPersonalInventory(player)
	end

	return {
		personal = personal,
		team = InventoryService.GetTeamInventory(),
		carryCaps = Resources.GetCarryCaps and Resources.GetCarryCaps() or nil,
		depositableResources = table.clone(DEPOSITABLE_RESOURCES),
		devStarterResourcesEnabled = Constants.DEV_GRANT_STARTER_RESOURCES == true,
	}
end

function InventoryService.BroadcastState(player: Player?)
	local resourceStateChanged = getResourceStateEvent()
	if not resourceStateChanged then
		return
	end

	if player then
		resourceStateChanged:FireClient(player, InventoryService.GetPublicState(player))
		return
	end

	for _, targetPlayer in ipairs(Players:GetPlayers()) do
		resourceStateChanged:FireClient(targetPlayer, InventoryService.GetPublicState(targetPlayer))
	end
end

function InventoryService.HandleDepositRequest(player: Player, payload)
	if typeof(payload) ~= "table" then
		payload = {}
	end

	local resourceType = payload.resourceType
	local amount = payload.amount
	local success, result

	if resourceType == nil then
		success, result = InventoryService.DepositAll(player)
	else
		if amount ~= nil and not toPositiveInteger(amount) then
			warn(string.format("[InventoryService] Rejected deposit from %s: InvalidAmount", player.Name))
			return
		end
		success, result = InventoryService.DepositResource(player, resourceType, amount)
	end

	if not success then
		warn(string.format("[InventoryService] Rejected deposit from %s: %s", player.Name, tostring(result)))
		InventoryService.BroadcastState(player)
	end
end

return InventoryService
