local Rep = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local Net = require(Rep.Remotes.Net)
local Atmos = require(Rep.Shared.Config.Atmosphere)

local cc = Instance.new("ColorCorrectionEffect", Lighting)
local bloom = Instance.new("BloomEffect", Lighting)
local dof = Instance.new("DepthOfFieldEffect", Lighting)
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere", Lighting)

local function apply(presetName, omen)
  local P = Atmos.Presets[presetName] or Atmos.Presets.Eerie
  -- Lighting
  for k,v in pairs(P.Lighting) do Lighting[k] = v end
  -- Atmosphere
  for k,v in pairs(P.Atmosphere) do atmosphere[k] = v end
  if omen == "BloodMoon" then
    atmosphere.Color = Color3.fromRGB(255, 120, 120)
    atmosphere.Decay = Color3.fromRGB(120, 20, 20)
  end
  -- Omen adjustments (subtle)
  if omen == "Fog" then atmosphere.Density = atmosphere.Density + 0.15 end
  if omen == "Eclipse" then Lighting.ClockTime = 0; cc.Brightness = cc.Brightness - 0.15 end
  if omen == "Aurora" then cc.Saturation = cc.Saturation + 0.2 end
  if omen == "Storm" then bloom.Intensity = bloom.Intensity + 0.2 end
  -- CC/Bloom/DOF
  for k,v in pairs(P.ColorCorrection) do cc[k] = v end
  for k,v in pairs(P.Bloom) do bloom[k] = v end
  for k,v in pairs(P.DepthOfField) do dof[k] = v end
end

-- reduce flashes → tone down bloom DOF in accessibility setting
local function applyReduceFlashes()
  bloom.Intensity = math.min(bloom.Intensity, 0.35)
  dof.Enabled = false
end

Net.BroadcastState.OnClientEvent:Connect(function(s)
  if s.atmospherePreset or s.omen then
    apply(s.atmospherePreset or Atmos.current, s.omen)
  end
end)

-- Initial
apply(Atmos.current)

-- Respect reduceFlashes if already set in profile snapshot (poll once)
task.spawn(function()
  local ok, prof = pcall(function() return require(Rep.Remotes.Net).GetProfile:InvokeServer() end)
  if ok and prof and prof.settings and prof.settings.accessibility and prof.settings.accessibility.reduceFlashes then
    applyReduceFlashes()
  end
end)
