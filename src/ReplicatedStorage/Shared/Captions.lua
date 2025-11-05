local M = {}
local queue = {}
local active = false

local function showNext()
	if active or #queue == 0 then return end
	active = true
	local item = table.remove(queue, 1)
	if item.cb then item.cb(item.text) end
	task.delay(item.dur or 2.5, function()
		if item.cb then item.cb("") end
		active = false
		showNext()
	end)
end

function M.push(text, dur, cb)
	table.insert(queue, {text=text, dur=dur, cb=cb})
	showNext()
end

return M
