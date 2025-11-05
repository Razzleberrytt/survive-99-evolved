local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local AdminPerform = Remotes:WaitForChild("Admin_Perform")
local Admin = {}
function Admin.Perform(action, payload)
  AdminPerform:FireServer({ action = action, payload = payload })
end
return Admin
