local Rep = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local SSS = game:GetService("ServerScriptService")

local M = {}
local workers = {}
local nextIndex = 1
local MAX = 6

local function ensureWorkers()
	local folder = SSS:FindFirstChild("Actors") or Instance.new("Folder", SSS); folder.Name = "Actors"
	-- If none, create a simple default worker Actor
	local has = false
	for _, ch in ipairs(folder:GetChildren()) do if ch:IsA("Actor") then has = true end end
	if not has then
		local actor = Instance.new("Actor"); actor.Name = "SquadWorker"; actor.Parent = folder
		local scriptModule = Instance.new("Script"); scriptModule.Name = "SquadWorker.server"
		scriptModule.Source = [[
			local Actor = script.Parent :: Actor
			Actor:BindToMessageParallel("ComputeOrder", function(payload)
				-- Compute a simple order from payload later
				Actor:SendMessage("OrderResult", { type = "Probe" })
			end)
		]]
		scriptModule.Parent = actor
	end
	-- refresh table
	table.clear(workers)
	for _, a in ipairs(folder:GetChildren()) do
		if a:IsA("Actor") then table.insert(workers, a) end
	end
	while #workers < MAX do
		local clone = folder:FindFirstChildWhichIsA("Actor"):Clone()
		clone.Parent = folder
		table.insert(workers, clone)
	end
end

function M.AssignSquadActors()
	ensureWorkers()
end

function M.SendPerceptionAndGetOrders(payload)
	if #workers == 0 then ensureWorkers() end
	local worker = workers[nextIndex]; nextIndex += 1; if nextIndex > #workers then nextIndex = 1 end
	local order
	local bind; bind = worker:BindToMessage("OrderResult", function(o) order = o end)
	worker:SendMessage("ComputeOrder", payload)
	local t0 = os.clock()
	while not order and os.clock() - t0 < 0.05 do task.wait() end
	if bind then bind:Disconnect() end
	return order or { type = "Probe" }
end

return M
