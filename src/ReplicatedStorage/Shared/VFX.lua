local M = {}

function M.spawnBillboardText(parent: Instance, text: string, lifetime: number)
	if not (parent and parent:IsA("BasePart")) then return end
	local gui = Instance.new("BillboardGui")
	gui.Size = UDim2.new(0, 0, 0, 0)
	gui.StudsOffset = Vector3.new(0, 3, 0)
	gui.AlwaysOnTop = true
	gui.Parent = parent

	local tl = Instance.new("TextLabel")
	tl.Size = UDim2.new(0, 0, 0, 0)
	tl.BackgroundTransparency = 1
	tl.Text = text
	tl.TextScaled = true
	tl.Font = Enum.Font.GothamBold
	tl.TextStrokeTransparency = 0.5
	tl.Parent = gui

	task.spawn(function()
		local t = 0
		while t < lifetime do
			t += task.wait()
			gui.StudsOffset = Vector3.new(0, 3 + t*1.5, 0)
			tl.TextTransparency = math.clamp(t / lifetime, 0, 1)
		end
		gui:Destroy()
	end)
end

return M
