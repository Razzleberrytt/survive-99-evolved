local PolicyService = game:GetService("PolicyService")
local Players = game:GetService("Players")

local PolicyGuard = {}
local _cache: { [number]: { ts: number, allowMonetization: boolean } } = {}
local TTL = 300 -- seconds

local function fetchPolicy(player: Player)
  local now = os.time()
  local c = _cache[player.UserId]
  if c and (now - c.ts) < TTL then
    return c.allowMonetization
  end

  local ok, info = pcall(function()
    return PolicyService:GetPolicyInfoForPlayerAsync(player)
  end)

  -- Conservatively deny on failure
  local allowed = false
  if ok and type(info) == "table" then
    -- Fields vary by region; treat any "paid items not allowed" flags as deny.
    -- Prefer strict default unless policy clearly allows.
    local possible = {
      info.IsPaidItemAllowed,
      info.InAppPurchaseAllowed,
      info.ArePaidRandomItemsRestricted == false,
    }
    for _, v in ipairs(possible) do
      if v == true then
        allowed = true
      end
    end
  end

  _cache[player.UserId] = { ts = now, allowMonetization = allowed }
  return allowed
end

function PolicyGuard.canMonetize(player: Player): boolean
  if not player then return false end
  return fetchPolicy(player)
end

-- Optional: clear cache when players leave
Players.PlayerRemoving:Connect(function(p)
  _cache[p.UserId] = nil
end)

return PolicyGuard
