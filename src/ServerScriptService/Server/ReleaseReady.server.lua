local Rep = game:GetService("ReplicatedStorage")
local FeatureFlags = require(Rep.Shared.Config.FeatureFlags)
local Store = require(Rep.Shared.Config.Store)

game.Players.PlayerAdded:Connect(function(plr)
	plr.Chatted:Connect(function(msg)
		if msg:lower():match("^/release") then
			print("=== RELEASE READY CHECK ===")
			print("1) Icons/Thumbs: use /iconscene then /iconA/B/C and Studio > Screenshot.")
			print("2) Store IDs filled:", next(Store.DevProducts or {}) and "YES" or "NO")
			print("3) SoftLaunch flag:", FeatureFlags.softLaunch and "ON (consider OFF for full launch)" or "OFF")
			print("4) Age/Policy: verify Game Settings > Monetization & Permissions.")
			print("5) Description/Keywords: update Experience details.")
			print("6) QA on mobile (FPS/RTT overlay).")
			print("7) MemoryStore live overrides set (if used).")
		end
	end)
end)
