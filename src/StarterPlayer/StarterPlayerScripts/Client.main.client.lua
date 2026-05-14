local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

if RunService:IsStudio() then
	local success, plasma = pcall(function()
		return require(ReplicatedStorage.Packages.plasma)
	end)
	if success then
		-- TODO: mount debugger UI for Matter world inspection.
	end
end

print("Client HUD bootstrap")

local UserInputService = game:GetService("UserInputService")
local Net = require(ReplicatedStorage.Remotes.Net)

local function fireMelee()
	Net.Input_Attack:FireServer({ weaponId = "melee", t = time() })
end

UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.KeyCode == Enum.KeyCode.F then
		fireMelee()
	elseif input.UserInputType == Enum.UserInputType.Touch then
		fireMelee()
	elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
		local camera = workspace.CurrentCamera
		if camera then
			Net.Input_Fire:FireServer({ weaponId = "pistol", origin = camera.CFrame.Position, dir = camera.CFrame.LookVector, t = time() })
		end
	end
end)
