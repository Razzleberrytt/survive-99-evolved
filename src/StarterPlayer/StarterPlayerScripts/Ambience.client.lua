local SoundService = game:GetService("SoundService")
local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)

local tracks = {
  base = "rbxassetid://0",   -- low wind / night hum
  tension = "rbxassetid://0",-- subtle drones
  storm = "rbxassetid://0",  -- rumble
  eclipse = "rbxassetid://0" -- eerie chorus
}

local function ensure(id)
  local s = Instance.new("Sound")
  s.SoundId = id; s.Looped = true; s.Volume = 0.3; s.Parent = SoundService
  s:Play()
  return s
end

local base = ensure(tracks.base)
local tension = ensure(tracks.tension)
local storm = ensure(tracks.storm) storm.Volume = 0
local eclipse = ensure(tracks.eclipse) eclipse.Volume = 0

Net.BroadcastState.OnClientEvent:Connect(function(s)
  if s.phase then
    tension.Volume = (s.phase == "Night") and 0.4 or 0.1
  end
  if s.omen then
    storm.Volume = (s.omen == "Storm") and 0.5 or 0
    eclipse.Volume = (s.omen == "Eclipse") and 0.35 or 0
  end
end)
