local M = {
  current = "Eerie",
  Presets = {
    Eerie = {
      Lighting = {
        Ambient = Color3.fromRGB(55,55,65),
        OutdoorAmbient = Color3.fromRGB(15,15,25),
        Brightness = 1.75,
        ClockTime = 23,
        ExposureCompensation = -0.15,
        Technology = Enum.Technology.Future
      },
      Atmosphere = { Density = 0.55, Offset = 0.2, Color = Color3.fromRGB(160,180,210), Decay = Color3.fromRGB(30,35,45), Glare = 0.0, Haze = 1.1 },
      ColorCorrection = { Brightness = -0.05, Contrast = 0.25, Saturation = -0.15, TintColor = Color3.fromRGB(230,235,255) },
      Bloom = { Intensity = 0.6, Threshold = 1.0, Size = 24 },
      DepthOfField = { Enabled = false, FocusDistance = 50, InFocusRadius = 30, NearIntensity = 0.05, FarIntensity = 0.15 }
    },
    Dusk = {
      Lighting = { Ambient = Color3.fromRGB(70,70,80), OutdoorAmbient = Color3.fromRGB(40,40,60), Brightness = 2.0, ClockTime = 19.2, ExposureCompensation = 0.0, Technology = Enum.Technology.Future },
      Atmosphere = { Density = 0.35, Offset = 0.05, Color = Color3.fromRGB(255,210,160), Decay = Color3.fromRGB(120,90,70), Glare = 0.0, Haze = 0.8 },
      ColorCorrection = { Brightness = 0.0, Contrast = 0.18, Saturation = 0.1, TintColor = Color3.fromRGB(255,245,230) },
      Bloom = { Intensity = 0.45, Threshold = 1.1, Size = 20 },
      DepthOfField = { Enabled = false, FocusDistance = 60, InFocusRadius = 40, NearIntensity = 0.03, FarIntensity = 0.1 }
    },
    Clear = {
      Lighting = { Ambient = Color3.fromRGB(120,120,120), OutdoorAmbient = Color3.fromRGB(135,135,135), Brightness = 3.0, ClockTime = 12, ExposureCompensation = 0.1, Technology = Enum.Technology.Future },
      Atmosphere = { Density = 0.15, Offset = 0.0, Color = Color3.fromRGB(200,220,255), Decay = Color3.fromRGB(170,190,210), Glare = 0, Haze = 0.2 },
      ColorCorrection = { Brightness = 0.05, Contrast = 0.0, Saturation = 0.0, TintColor = Color3.fromRGB(255,255,255) },
      Bloom = { Intensity = 0.25, Threshold = 1.2, Size = 16 },
      DepthOfField = { Enabled = false, FocusDistance = 80, InFocusRadius = 60, NearIntensity = 0.0, FarIntensity = 0.05 }
    }
  }
}
return M
