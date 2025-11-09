local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Remotes = Instance.new("Folder")
Remotes.Name = "PolicyRemotes"
Remotes.Parent = ReplicatedStorage

local GetPolicyFlags = Instance.new("RemoteFunction")
GetPolicyFlags.Name = "GetPolicyFlags"
GetPolicyFlags.Parent = Remotes

return {
  Folder = Remotes,
  GetPolicyFlags = GetPolicyFlags,
}
