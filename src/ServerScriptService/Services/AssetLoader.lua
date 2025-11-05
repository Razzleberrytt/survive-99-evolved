local Rep = game:GetService("ReplicatedStorage")
local Assets = Rep:FindFirstChild("Assets")

local M = {}

-- Expected path: ReplicatedStorage/Assets/Models/Enemies/<Kind>
-- The <Kind> folder can be a Model or a Folder with a Model child named "Rig".
function M.GetEnemyModel(kind: string)
  if not Assets then return nil end
  local folder = Assets:FindFirstChild("Models")
  folder = folder and folder:FindFirstChild("Enemies")
  local node = folder and folder:FindFirstChild(kind)
  if not node then return nil end
  local model = node:IsA("Model") and node or node:FindFirstChild("Rig")
  if model and model:IsA("Model") then
    return model
  end
  return nil
end

function M.CloneEnemy(kind, position)
  local src = M.GetEnemyModel(kind)
  if not src then return nil end
  local m = src:Clone()
  m.Name = "Enemy_"..kind
  m:PivotTo(CFrame.new(position))
  m.Parent = workspace
  -- ensure root part & collisions enabled
  local root = m.PrimaryPart or m:FindFirstChildWhichIsA("BasePart")
  if root then root.Anchored = false end
  return m
end

return M
