local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemoteNames = require(ReplicatedStorage.Shared.Remotes.RemoteNames)

local RemoteService = {}
local initialized = false
local remotesFolder: Folder? = nil

local REMOTE_CLASSES = {
	[RemoteNames.PhaseStateChanged] = "RemoteEvent",
	[RemoteNames.BeaconStateChanged] = "RemoteEvent",
	[RemoteNames.RequestNightStartVote] = "RemoteEvent",
	[RemoteNames.ResourceStateChanged] = "RemoteEvent",
	[RemoteNames.RequestDepositResource] = "RemoteEvent",
}

local function getFolder(): Folder
	local folder = remotesFolder or ReplicatedStorage:FindFirstChild("Remotes")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Remotes"
		folder.Parent = ReplicatedStorage
	end

	remotesFolder = folder :: Folder
	return remotesFolder :: Folder
end

local function ensureRemote(name: string, className: string): Instance
	local folder = getFolder()
	local existing = folder:FindFirstChild(name)
	if existing then
		if not existing:IsA(className) then
			warn(string.format("[RemoteService] %s exists as %s, expected %s", name, existing.ClassName, className))
		end
		return existing
	end

	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = folder
	return remote
end

function RemoteService.Init()
	if initialized then
		return
	end

	for name, className in pairs(REMOTE_CLASSES) do
		ensureRemote(name, className)
	end

	initialized = true
end

function RemoteService.GetRemote(name: string): Instance?
	local className = REMOTE_CLASSES[name]
	if not className then
		warn(string.format("[RemoteService] Unknown remote requested: %s", name))
		return nil
	end

	return ensureRemote(name, className)
end

function RemoteService.GetEvent(name: string): RemoteEvent?
	local remote = RemoteService.GetRemote(name)
	if remote and remote:IsA("RemoteEvent") then
		return remote
	end

	return nil
end

return RemoteService
