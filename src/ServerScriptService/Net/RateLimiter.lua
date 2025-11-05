export type RateLimiter = (Player) -> boolean

local Players = game:GetService("Players")

return function(capacity: number, refillPerSec: number): RateLimiter
  local buckets: { [number]: { tokens: number, t: number } } = {}

  Players.PlayerRemoving:Connect(function(player)
    buckets[player.UserId] = nil
  end)

  local function step(player: Player)
    local userId = player.UserId
    local now = os.clock()
    local bucket = buckets[userId]
    if not bucket then
      bucket = { tokens = capacity, t = now }
      buckets[userId] = bucket
    else
      local dt = math.max(0, now - bucket.t)
      bucket.tokens = math.min(capacity, bucket.tokens + dt * refillPerSec)
      bucket.t = now
    end
    return bucket
  end

  return function(player: Player)
    local bucket = step(player)
    if bucket.tokens >= 1 then
      bucket.tokens -= 1
      return true
    end
    return false
  end
end
