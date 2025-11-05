local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")

local queue = MemoryStoreService:GetQueue("AdminAudit_v1", 1024)
local store = DataStoreService:GetDataStore("AdminAudit_v1")

local function now()
  return DateTime.now().UnixTimestampMillis
end

local M = {}

local function sanitize(value, depth)
  depth = depth or 1
  if value == nil then
    return nil
  end

  if depth > 4 then
    return "<depth>"
  end

  local kind = typeof(value)
  if kind == "boolean" or kind == "number" or kind == "string" then
    return value
  end

  if kind == "table" then
    local result = {}
    local index = 0
    for key, item in pairs(value) do
      index += 1
      if index > 32 then
        break
      end
      local safeKey = sanitize(key, depth + 1)
      if type(safeKey) ~= "string" and type(safeKey) ~= "number" then
        safeKey = tostring(safeKey)
      end
      result[safeKey] = sanitize(item, depth + 1)
    end
    return result
  end

  if kind == "Instance" then
    local ok, fullName = pcall(function()
      return value:GetFullName()
    end)
    if ok then
      return "<Instance:" .. fullName .. ">"
    end
    return "<Instance>"
  end

  if kind == "Vector3" or kind == "CFrame" or kind == "Color3" or kind == "UDim2" then
    return tostring(value)
  end

  return tostring(value)
end

-- Non-blocking enqueue (ephemeral, 6h TTL)
function M.enqueue(entry)
  entry.ts = entry.ts or now()
  pcall(function()
    queue:AddAsync(entry, 6 * 60 * 60)
  end)
end

-- Opportunistic, bounded daily append (persistent)
function M.persist(entry)
  entry.ts = entry.ts or now()
  local key = os.date("!%Y-%m-%d")
  pcall(function()
    store:UpdateAsync(key, function(old)
      old = old or {}
      table.insert(old, entry)
      -- Trim to last 200 entries/day to stay small
      local max = 200
      if #old > max then
        old = { unpack(old, #old - max + 1) }
      end
      return old
    end)
  end)
end

function M.log(action, actorId, payload, ok, msg)
  local entry = {
    action = tostring(action or ""),
    actorId = tonumber(actorId) or 0,
    payload = sanitize(payload),
    ok = ok and true or false,
    msg = sanitize(msg),
  }
  M.enqueue(entry)
  M.persist(entry)
end

return M
