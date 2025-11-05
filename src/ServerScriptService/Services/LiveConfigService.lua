local MemoryStoreService = game:GetService("MemoryStoreService")
local Rep = game:GetService("ReplicatedStorage")

local FeatureFlags = require(Rep.Shared.Config.FeatureFlags)
local Tuning = require(Rep.Shared.Config.Tuning)

local M = {
	FeatureFlags = table.clone(FeatureFlags),
	Tuning = table.clone(Tuning),
}

local function applyOverride(dst, src)
	for k,v in pairs(src) do
		if type(v) == "table" and type(dst[k]) == "table" then
			applyOverride(dst[k], v)
		else
			dst[k] = v
		end
	end
end

local function fetchMemoryStore()
	local ok, data = pcall(function()
		local map = MemoryStoreService:GetMap("Survive99_LiveConfig_v1")
		return map:GetAsync("live") -- expects {FeatureFlags={...}, Tuning={...}}
	end)
	if ok and data then
		if data.FeatureFlags then applyOverride(M.FeatureFlags, data.FeatureFlags) end
		if data.Tuning then applyOverride(M.Tuning, data.Tuning) end
	end
end

function M.Start()
	task.spawn(function()
		while true do
			fetchMemoryStore()
			task.wait(60)
		end
	end)
end

return M
