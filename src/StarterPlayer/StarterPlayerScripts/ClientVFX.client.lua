local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local VFX = require(Rep.Shared.VFX)

Net.SpawnVFX.OnClientEvent:Connect(function(payload)
	-- payload = { kind="damage"|"hit"|"text", part=Instance, amount=number, text=string }
	if not payload then return end
	if payload.kind == "damage" and payload.part then
		VFX.spawnBillboardText(payload.part, tostring(payload.amount), 1.1)
	elseif payload.kind == "text" and payload.part then
		VFX.spawnBillboardText(payload.part, payload.text or "", 1.4)
	end
end)
