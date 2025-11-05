local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local BeaconService = require(script.Parent.BeaconService)
local Net = require(Rep.Remotes.Net)
local DataService = require(script.Parent.DataService)

local M = {}
local activeRescue = nil

local function makeRescuee(pos)
	local p = Instance.new("Part")
	p.Name = "Rescuee"
	p.Size = Vector3.new(2,3,2)
	p.Color = Color3.fromRGB(130, 190, 255)
	p.Anchored = false
	p.CanCollide = true
	p.Position = pos + Vector3.new(0,2,0)
	p.Parent = workspace
	return p
end

function M.GenerateDailyRescues()
	if activeRescue then return end
	local theta = math.random() * math.pi * 2
	local r = math.random(80, 140)
	local pos = Vector3.new(math.cos(theta)*r, 0, math.sin(theta)*r)
	local npc = makeRescuee(pos)
	activeRescue = { inst = npc, state = "Waiting", escorter = nil }
	Net.BroadcastState:FireAllClients({ rescue = "spawned" })
end

function M.Interact(player, id, action)
	if not activeRescue or not activeRescue.inst then return false end
	if (activeRescue.inst.Position - player.Character.PrimaryPart.Position).Magnitude > 12 then return false end
	if action == "Escort" and activeRescue.state == "Waiting" then
		activeRescue.state = "Escorting"
		activeRescue.escorter = player.UserId
		return true
	end
	return false
end

-- Tick from GameService or a RunService heartbeat (MVP: simple connection here)
game:GetService("RunService").Stepped:Connect(function()
	if not activeRescue or not activeRescue.inst then return end
	if activeRescue.state == "Escorting" then
		local target = BeaconService.GetCFrame().Position
		local dir = (target - activeRescue.inst.Position)
		if dir.Magnitude > 4 then
			local v = dir.Unit * 10
			activeRescue.inst.AssemblyLinearVelocity = Vector3.new(v.X, activeRescue.inst.AssemblyLinearVelocity.Y, v.Z)
		else
			-- Arrived!
			DataService.GrantBlueprintOrToken(activeRescue.escorter)
			if activeRescue.inst.Parent then activeRescue.inst:Destroy() end
			activeRescue = nil
			Net.BroadcastState:FireAllClients({ rescue = "complete" })
		end
	end
end)

return M
