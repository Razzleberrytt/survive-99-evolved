local M = {}

local function billboardText(parent: Instance, text: string, lifetime: number)
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

local function ringBurst(position: Vector3, color: Color3?, lifetime: number?)
	local p = Instance.new("Part")
	p.Anchored = true; p.CanCollide = false; p.Transparency = 1
	p.Size = Vector3.new(1,0.2,1); p.CFrame = CFrame.new(position); p.Parent = workspace
	local a = Instance.new("Attachment", p)
	local pe = Instance.new("ParticleEmitter", a)
	pe.Texture = "rbxassetid://0" -- placeholder; swap with your ring texture
	pe.Color = ColorSequence.new(color or Color3.fromRGB(255, 220, 120))
	pe.Lifetime = NumberRange.new(lifetime or 0.8)
	pe.Rate = 0
	pe.Speed = NumberRange.new(0)
	pe.Size = NumberSequence.new{
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 6)
	}
	pe:Emit(1)
	game:GetService("Debris"):AddItem(p, (lifetime or 0.8) + 0.2)
end

function M.spawnBillboardText(parent, text, lifetime) billboardText(parent, text, lifetime or 1.1) end
function M.spawnRingBurst(pos, color, lifetime) ringBurst(pos, color, lifetime) end

return M
