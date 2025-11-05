local Rep = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Net = require(Rep.Remotes.Net)
local plr = Players.LocalPlayer

local gui = Instance.new("ScreenGui"); gui.Name="CosmeticsShop"; gui.ResetOnSpawn=false; gui.Parent=plr:WaitForChild("PlayerGui")
local frame = Instance.new("Frame"); frame.Size=UDim2.new(0,360,0,300); frame.Position=UDim2.new(0,12,0,200); frame.BackgroundTransparency=0.2; frame.Visible=false; frame.Parent=gui
local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(1,0,0,28); lbl.Text="Daily Shop"; lbl.BackgroundTransparency=1; lbl.Font=Enum.Font.GothamBold; lbl.Parent=frame
local list = Instance.new("Frame"); list.Size=UDim2.new(1,-12,1,-40); list.Position=UDim2.new(0,6,0,36); list.BackgroundTransparency=1; list.Parent=frame

local function clear() for _,c in ipairs(list:GetChildren()) do if c:IsA("TextButton") or c:IsA("TextLabel") then c:Destroy() end end end

local function refresh()
	clear()
	local shop = Net.ListCosmetics:InvokeServer()
	local y = 0
	for _, id in ipairs(shop.items) do
		local it = shop.catalog[id]
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(1, -12, 0, 32); b.Position = UDim2.new(0,6,0,y); y += 36
		b.Text = string.format("%s (%s) — %d shards", it.name, it.type, it.cost or 0)
		b.Parent = list
		b.MouseButton1Click:Connect(function()
			local ok, why = Net.BuyCosmetic:InvokeServer(id)
			if not ok and why ~= "owned" then
				lbl.Text = "Need shards or not in rotation."
			else
				Net.EquipCosmetic:InvokeServer(id)
				lbl.Text = "Equipped: "..it.name
			end
		end)
	end
end

-- Toggle button
local toggle = Instance.new("TextButton")
toggle.Size=UDim2.new(0,120,0,36); toggle.Position=UDim2.new(0,12,1,-56); toggle.AnchorPoint=Vector2.new(0,1)
toggle.Text="Cosmetics"; toggle.Parent=gui
toggle.MouseButton1Click:Connect(function()
	frame.Visible = not frame.Visible
	if frame.Visible then refresh() end
end)
