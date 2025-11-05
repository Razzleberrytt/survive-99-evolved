local LogService = game:GetService("LogService")
local Rep = game:GetService("ReplicatedStorage")
local MemoryStoreService = game:GetService("MemoryStoreService")

local M = {}
local map = MemoryStoreService:GetQueue("Survive99_Bugs_v1", 1000)

local function push(payload)
	local ok, err = pcall(function()
		map:AddAsync(game.HttpService:JSONEncode(payload), 60*60) -- 1 hour TTL
	end)
	if not ok then warn("[BugReport] push fail", err) end
end

function M.Start()
	LogService.MessageOut:Connect(function(msg, msgType)
		if msgType == Enum.MessageType.MessageError or msgType == Enum.MessageType.MessageWarning then
			push({ t=os.time(), type=tostring(msgType), msg=msg })
		end
	end)
end

return M
