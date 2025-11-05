local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "Remotes"
	remotesFolder.Parent = ReplicatedStorage
end

local function getRemote(name: string, className: string)
	local remote = remotesFolder:FindFirstChild(name)
	if not remote then
		remote = Instance.new(className)
		remote.Name = name
		remote.Parent = remotesFolder
	end
	return remote
end

return {
	PlaceRequest = getRemote("PlaceRequest", "RemoteFunction"),
	RepairRequest = getRemote("RepairRequest", "RemoteFunction"),
	FuelBeacon = getRemote("FuelBeacon", "RemoteFunction"),
	RescueInteract = getRemote("RescueInteract", "RemoteFunction"),
	NightStartVote = getRemote("NightStartVote", "RemoteEvent"),
	BroadcastState = getRemote("BroadcastState", "RemoteEvent"),
}
