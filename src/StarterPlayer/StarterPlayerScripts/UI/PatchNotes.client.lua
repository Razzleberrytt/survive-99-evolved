local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Players = game:GetService("Players")
local plr = Players.LocalPlayer

local gui = Instance.new("ScreenGui"); gui.Name="PatchNotes"; gui.ResetOnSpawn=false; gui.Parent=plr:WaitForChild("PlayerGui")
local frame = Instance.new("Frame"); frame.Size=UDim2.new(0,420,0,260); frame.Position=UDim2.new(0.5,-210,0.5,-130); frame.BackgroundTransparency=0.15; frame.Visible=false; frame.Parent=gui
local title = Instance.new("TextLabel"); title.Size=UDim2.new(1,0,0,36); title.Font=Enum.Font.GothamBlack; title.BackgroundTransparency=1; title.Text=""; title.Parent=frame
local body = Instance.new("TextLabel"); body.Size=UDim2.new(1,-16,1,-60); body.Position=UDim2.new(0,8,0,46); body.BackgroundTransparency=1; body.TextWrapped=true; body.TextYAlignment=Enum.TextYAlignment.Top; body.Font=Enum.Font.Gotham; body.Parent=frame
local okBtn = Instance.new("TextButton"); okBtn.Size=UDim2.new(0,100,0,28); okBtn.Position=UDim2.new(1,-108,1,-36); okBtn.Text="OK"; okBtn.Parent=frame
okBtn.MouseButton1Click:Connect(function() frame.Visible=false end)

Net.PatchNotesEvt.OnClientEvent:Connect(function(notes)
	title.Text = (notes.title or "Update").." v"..tostring(notes.version)
	body.Text = "- "..table.concat(notes.bullets or {}, "\n- ")
	frame.Visible = true
end)
