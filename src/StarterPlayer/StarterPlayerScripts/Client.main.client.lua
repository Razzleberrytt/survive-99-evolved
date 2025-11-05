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
