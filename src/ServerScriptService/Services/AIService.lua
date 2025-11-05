--!strict

local ServerScriptService = game:GetService("ServerScriptService")

type Actor = typeof(Instance.new("Actor"))

local AIService = {}

local workers: { Actor } = {}
local nextWorkerIndex = 1
local actorsFolder = ServerScriptService:WaitForChild("Actors")

local function ensureWorkers()
	-- TODO: spawn up to 6 worker Actors, bind message handlers.
end

function AIService.assignSquadActors()
	ensureWorkers()
end

function AIService.sendPerceptionAndGetOrders(payload)
	ensureWorkers()
	local worker = workers[nextWorkerIndex]
	nextWorkerIndex = (nextWorkerIndex % math.max(1, #workers)) + 1
	if worker then
		worker:SendMessage("ComputeOrder", payload)
	end
end

return AIService
