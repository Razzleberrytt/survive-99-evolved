local Rep = game:GetService("ReplicatedStorage")
local Matter = require(Rep.Packages.matter)
local InstanceRef = require(Rep.Components.C_InstanceRef)
local Boss = require(Rep.Components.C_Boss)
local EnemyType = require(Rep.Components.C_EnemyType)
local Net = require(Rep.Remotes.Net)
local BeaconService = require(game.ServerScriptService.Services.BeaconService)

local function makeTelegraphRing(pos, radius)
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.Name = "Telegraph"
	p.Size = Vector3.new(1,0.2,1); p.Color = Color3.fromRGB(255, 180, 90)
	p.Material = Enum.Material.Neon; p.CFrame = CFrame.new(pos)
	p.Parent = workspace
	local a0 = Instance.new("Attachment", p)
	local p0 = Instance.new("ParticleEmitter", a0)
	p0.Texture = "rbxassetid://0" -- placeholder
	p0.Rate = 0; p0.Lifetime = NumberRange.new(1)
	game:GetService("Debris"):AddItem(p, 2)
	return p
end

return function(world, dt)
	for id, boss, ref, et in world:query(Boss, InstanceRef, EnemyType) do
		if et.kind ~= "Miniboss" then continue end
		boss.stompCd -= dt
		if boss.stompCd <= 0 and ref.inst then
			-- Pre-warn
			local pos = ref.inst.Position
			makeTelegraphRing(pos, 18)
			Net.PlaySound:FireAllClients({key="stomp", vol=0.9})
			task.delay(boss.telegraph, function()
				-- Apply shockwave
				local radius = 18
				for _, inst in ipairs(workspace:GetDescendants()) do
					if inst:IsA("BasePart") then
						local d = (inst.Position - pos).Magnitude
						if d < radius then
							local dir = (inst.Position - pos).Unit
							inst.AssemblyLinearVelocity += dir * 50
						end
					end
				end
				Net.SpawnVFX:FireAllClients({ kind="particle", position = pos, lifetime = 0.9, })
				-- Beacon fuel nudge
				local dBeacon = (BeaconService.GetCFrame().Position - pos).Magnitude
				if dBeacon < 60 then BeaconService.ApplyFuel(-3) end
			end)
			boss.stompCd = boss.stompMax
		end
	end
end
