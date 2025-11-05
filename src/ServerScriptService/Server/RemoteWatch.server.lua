local Rep = game:GetService("ReplicatedStorage")
local Net = require(Rep.Remotes.Net)
local Players = game:GetService("Players")

local window = 5 -- seconds
local limits = {
	NightStartVote = { burst = 6 },
}
local counters = {} -- [userId][key] = {count, t0}

local function bump(userId, key)
	counters[userId] = counters[userId] or {}
	local slot = counters[userId][key] or {count=0, t0=os.clock()}
	local now = os.clock()
	if now - slot.t0 > window then slot.count = 0; slot.t0 = now end
	slot.count += 1
	counters[userId][key] = slot
	if limits[key] and slot.count > limits[key].burst then
		warn(("[RemoteWatch] %d spam on %s: %d in %ds"):format(userId, key, slot.count, window))
	end
end

-- Example: watch NightStartVote
Net.NightStartVote.OnServerEvent:Connect(function(player)
	if player and player.UserId then bump(player.UserId, "NightStartVote") end
end)

return {}
