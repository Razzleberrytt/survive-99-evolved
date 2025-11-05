local Rep = game:GetService("ReplicatedStorage")

local M = {}
local ROOT_NAME = "NavVolumes"

local function attachModifier(part: BasePart, label: string, passThrough: boolean)
	local old = part:FindFirstChildOfClass("PathfindingModifier")
	if old then old:Destroy() end
	local mod = Instance.new("PathfindingModifier")
	mod.Label = label
	mod.PassThrough = passThrough
	mod.Parent = part
end

function M.Bootstrap()
	local root = workspace:FindFirstChild(ROOT_NAME)
	if not root then
		root = Instance.new("Folder")
		root.Name = ROOT_NAME
		root.Parent = workspace
	end
	-- Convert any children with attributes:
	--   Nav="Block" => PassThrough=false
	--   Nav="HighCost" => Label=HighCost, PassThrough=true
	for _, ch in ipairs(root:GetDescendants()) do
		if ch:IsA("BasePart") then
			local nav = ch:GetAttribute("Nav")
			if nav == "Block" then attachModifier(ch, "Blocked", false) end
			if nav == "HighCost" then attachModifier(ch, "HighCost", true) end
		end
	end
end

return M
