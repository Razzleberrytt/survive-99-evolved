local DataStoreService = game:GetService("DataStoreService")
local MemoryStoreService = game:GetService("MemoryStoreService")
local queue = MemoryStoreService:GetQueue("AdminAudit_v1", 512)
local store = DataStoreService:GetDataStore("AdminAudit_v1")

local function now() return DateTime.now().UnixTimestampMillis end
local M = {}
function M.log(action, actorId, payload, ok, msg)
  local entry = { ts = now(), action = action, actorId = actorId, payload = payload, ok = ok and true or false, msg = msg }
  pcall(function() queue:AddAsync(entry, 6*60*60) end)
  pcall(function()
    store:UpdateAsync(os.date("!%Y-%m-%d"), function(old)
      old = old or {}
      table.insert(old, entry)
      if #old > 200 then old = { unpack(old, #old-199) } end
      return old
    end)
  end)
end
return M
