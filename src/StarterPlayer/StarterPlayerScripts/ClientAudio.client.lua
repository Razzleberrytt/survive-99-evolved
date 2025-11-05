local Rep = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local Net = require(Rep.Remotes.Net)

local sounds = {
	-- Replace with real IDs later
	beacon_on   = "rbxassetid://0",
	beacon_off  = "rbxassetid://0",
	stomp       = "rbxassetid://0",
	hit         = "rbxassetid://0",
	spike       = "rbxassetid://0",
	omen        = "rbxassetid://0",
	ui_click    = "rbxassetid://0",
}

local cache = {}
local function play(key, vol)
	local id = sounds[key]; if not id then return end
	local s = cache[key]
	if not s then
		s = Instance.new("Sound")
		s.SoundId = id
		s.Volume = vol or 0.7
		s.Parent = SoundService
		cache[key] = s
	end
	s.TimePosition = 0
	s:Play()
end

Net.PlaySound.OnClientEvent:Connect(function(payload)
	if type(payload)=="table" and payload.key then
		play(payload.key, payload.vol)
	elseif type(payload)=="string" then
		play(payload)
	end
end)

return {}
