local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local VFX = require(Rep.Shared.VFX)

Net.SpawnVFX.OnClientEvent:Connect(function(payload)
	if not payload then return end
	if payload.kind == "damage" and payload.part then
		VFX.spawnBillboardText(payload.part, tostring(payload.amount), 1.1)
	elseif payload.kind == "text" and payload.part then
		VFX.spawnBillboardText(payload.part, payload.text or "", 1.4)
	elseif payload.kind == "particle" and payload.position then
		VFX.spawnRingBurst(payload.position, payload.color, payload.lifetime)
	end
end)
