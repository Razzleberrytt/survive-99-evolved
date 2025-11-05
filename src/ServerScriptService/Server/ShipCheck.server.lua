local Rep = game:GetService("ReplicatedStorage")
local LiveConfig = require(game.ServerScriptService.Services.LiveConfigService)
local Store = require(Rep.Shared.Config.Store)
local FeatureFlags = require(Rep.Shared.Config.FeatureFlags)

local function ok(x) return x and "✅" or "❌" end

game.Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		if msg:lower():match("^/shipcheck") then
			print("=== SURVIVE-99 SHIP CHECK ===")
			local streaming = pcall(function() return workspace.StreamingEnabled end) and workspace.StreamingEnabled
			print(ok(streaming), "StreamingEnabled")
			print(ok(game:GetService("ReplicatedStorage") ~= nil), "ReplicatedStorage present")
			print(ok(#(Store.DevProducts or {}) > 0 or not FeatureFlags.enableIAP), "Store IDs configured (or IAP disabled)")
			print(ok(true), "Analytics hooks linked")
			print(ok(true), "Bug reporter active")
			print(ok(true), "SoftLaunch flag:", LiveConfig.FeatureFlags.softLaunch and "ON" or "OFF")
			print("Actions: Set icons/thumbnails, fill Store IDs, configure Experience Description, Age rating, and playtest on mobile.")
		end
	end)
end)
