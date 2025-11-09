local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
    RemotesFolder = Instance.new("Folder")
    RemotesFolder.Name = "Remotes"
    RemotesFolder.Parent = ReplicatedStorage
end

local Remotes = {}

function Remotes.create(name)
    local existing = RemotesFolder:FindFirstChild(name)
    if existing then return existing end
    local ev = Instance.new("RemoteEvent")
    ev.Name = name
    ev.Parent = RemotesFolder
    return ev
end

function Remotes.get(name)
    return RemotesFolder:FindFirstChild(name)
end

return Remotes
