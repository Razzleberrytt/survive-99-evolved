local Rep = game:GetService("ReplicatedStorage")
local Remotes = Rep:FindFirstChild("Remotes") or Instance.new("Folder", Rep)
Remotes.Name = "Remotes"
local function get(name, class)
	local r = Remotes:FindFirstChild(name)
	if not r then r = Instance.new(class) r.Name = name r.Parent = Remotes end
	return r
end
return {
	PlaceRequest   = get("PlaceRequest","RemoteFunction"),
	RepairRequest  = get("RepairRequest","RemoteFunction"),
	FuelBeacon     = get("FuelBeacon","RemoteFunction"),
	RescueInteract = get("RescueInteract","RemoteFunction"),
	GetProfile     = get("GetProfile","RemoteFunction"),
	NightStartVote = get("NightStartVote","RemoteEvent"),
	BroadcastState = get("BroadcastState","RemoteEvent"),
	BeaconChanged  = get("BeaconChanged","RemoteEvent"),
	SpawnVFX       = get("SpawnVFX","RemoteEvent"),
	TutorialEvent  = get("TutorialEvent","RemoteEvent"),
	PlaySound     = get("PlaySound","RemoteEvent"),
	ToggleSetting = get("ToggleSetting","RemoteFunction"),
	PurchaseProduct = get("PurchaseProduct","RemoteFunction"),
	PerfPing      = get("PerfPing","RemoteFunction"),
	Admin_Perform = get("Admin_Perform","RemoteFunction"),
}
