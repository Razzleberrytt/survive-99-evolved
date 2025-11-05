local ReplicatedStorage = game:GetService("ReplicatedStorage")

local RateLimiter = require(script.Parent.RateLimiter)

local RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not RemotesFolder then
  RemotesFolder = Instance.new("Folder")
  RemotesFolder.Name = "Remotes"
  RemotesFolder.Parent = ReplicatedStorage
end

local function ensureRemote(name: string, className: string): Instance
  local remote = RemotesFolder:FindFirstChild(name)
  if remote then
    return remote
  end
  remote = Instance.new(className)
  remote.Name = name
  remote.Parent = RemotesFolder
  return remote
end

local function defaultAllow(_player: Player): boolean
  return true
end

local function defaultSchema(_payload): boolean
  return true
end

local M = {}

export type RegisterOptions = {
  capacity: number?,
  refill: number?,
  permission: ((Player) -> boolean)?,
  onRateLimit: ((Player) -> (any))?,
  onDenied: ((Player) -> (any))?,
  onInvalid: ((Player, any) -> (any))?,
}

function M.registerEvent(name: string, schema: ((any) -> boolean)?, handler: (Player, any) -> (), opts: RegisterOptions?)
  opts = opts or {}
  local allow = opts.permission or defaultAllow
  local validate = schema or defaultSchema
  local limiter = RateLimiter(opts.capacity or 10, opts.refill or 2)
  local remote = ensureRemote(name, "RemoteEvent")

  remote.OnServerEvent:Connect(function(player: Player, payload)
    if not allow(player) then
      if opts and opts.onDenied then
        opts.onDenied(player)
      end
      return
    end
    if not limiter(player) then
      if opts and opts.onRateLimit then
        opts.onRateLimit(player)
      end
      return
    end
    if not validate(payload) then
      if opts and opts.onInvalid then
        opts.onInvalid(player, payload)
      end
      return
    end

    local ok, err = pcall(handler, player, payload)
    if not ok then
      warn(string.format("[Remote:%s] handler error: %s", name, err))
    end
  end)

  return remote
end

function M.registerFunction(name: string, schema: ((any) -> boolean)?, handler: (Player, any) -> (...any), opts: RegisterOptions?)
  opts = opts or {}
  local allow = opts.permission or defaultAllow
  local validate = schema or defaultSchema
  local limiter = RateLimiter(opts.capacity or 6, opts.refill or 1)
  local remote = ensureRemote(name, "RemoteFunction")

  remote.OnServerInvoke = function(player: Player, payload)
    if not allow(player) then
      if opts and opts.onDenied then
        return opts.onDenied(player)
      end
      return false, "forbidden"
    end

    if not limiter(player) then
      if opts and opts.onRateLimit then
        return opts.onRateLimit(player)
      end
      return false, "rate_limited"
    end

    if not validate(payload) then
      if opts and opts.onInvalid then
        return opts.onInvalid(player, payload)
      end
      return false, "bad_payload"
    end

    local ok, resultOrErr, ... = pcall(handler, player, payload)
    if not ok then
      warn(string.format("[Remote:%s] handler error: %s", name, resultOrErr))
      return false, "handler_error"
    end
    return resultOrErr, ...
  end

  return remote
end

return M
