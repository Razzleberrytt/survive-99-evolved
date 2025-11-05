local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local M = {}
local memory = {} -- studio fallback

function M.load(key, default)
	if RunService:IsStudio() then
		memory[key] = memory[key] or table.clone(default)
		return memory[key]
	end
	local ds = DataStoreService:GetDataStore("Survive99_Profile_v1")
	local ok, val = pcall(function() return ds:GetAsync(key) end)
	if ok and val then return val end
	return table.clone(default)
end

function M.save(key, value)
	if RunService:IsStudio() then
		memory[key] = value
		return true
	end
	local ds = DataStoreService:GetDataStore("Survive99_Profile_v1")
	local ok = pcall(function() ds:SetAsync(key, value) end)
	return ok
end

return M
