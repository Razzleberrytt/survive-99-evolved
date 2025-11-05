-- Spawns a static vignette (beacon + walls + enemies anchored) when requested.
local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local function clearNamed(name)
	for _, inst in ipairs(workspace:GetChildren()) do
		if inst.Name == name then inst:Destroy() end
	end
end

game.Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		if msg:lower():match("^/iconscene") then
			clearNamed("IconScene")
			local folder = Instance.new("Folder"); folder.Name = "IconScene"; folder.Parent = workspace

			local beacon = Instance.new("Part"); beacon.Name="BeaconIcon"; beacon.Anchored=true; beacon.Size=Vector3.new(4,8,4)
			beacon.Color=Color3.fromRGB(255,214,120); beacon.Material=Enum.Material.Neon
			beacon.CFrame = CFrame.new(0,4,0); beacon.Parent = folder

			local function wall(cf)
				local p=Instance.new("Part"); p.Name="WallIcon"; p.Anchored=true; p.Size=Vector3.new(4,4,1); p.CFrame=cf; p.Parent=folder
			end
			wall(CFrame.new(-8,2,-6)); wall(CFrame.new(8,2,-6)); wall(CFrame.new(0,2,-10))

			local function enemy(pos)
				local e=Instance.new("Part"); e.Name="EnemyIcon"; e.Anchored=true; e.Size=Vector3.new(2,3,2); e.Color=Color3.fromRGB(200,60,60)
				e.CFrame=CFrame.new(pos); e.Parent=folder
			end
			enemy(Vector3.new(-12,1,12)); enemy(Vector3.new(10,1,8)); enemy(Vector3.new(6,1,14))
		end
	end)
end)
