local Throttle = {}
local buckets = {} -- [userId][key] = {tokens, max, rate, last}
local DEFAULT_MAX, DEFAULT_RATE = 12, 8 -- burst, refill per second
local function getBucket(userId, key)
	buckets[userId] = buckets[userId] or {}
	local b = buckets[userId][key]
	if not b then b = {tokens = DEFAULT_MAX, max = DEFAULT_MAX, rate = DEFAULT_RATE, last = os.clock()} buckets[userId][key] = b end
	local now = os.clock()
	local dt = math.max(0, now - b.last)
	b.tokens = math.clamp(b.tokens + dt * b.rate, 0, b.max); b.last = now
	return b
end
function Throttle.consume(player, key, cost)
	local b = getBucket(player.UserId, key); cost = cost or 1
	if b.tokens >= cost then b.tokens -= cost return true else return false end
end
return Throttle
