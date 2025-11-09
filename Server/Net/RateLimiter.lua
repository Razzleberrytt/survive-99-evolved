local RateLimiter = {}
RateLimiter.__index = RateLimiter

function RateLimiter.new(rate, burst)
    return setmetatable({r=rate, b=burst, t=burst, last=os.clock()}, RateLimiter)
end

function RateLimiter:allow()
    local now = os.clock()
    self.t = math.min(self.b, self.t + (now - self.last) * self.r)
    self.last = now
    if self.t >= 1 then
        self.t -= 1
        return true
    end
    return false
end

return RateLimiter
