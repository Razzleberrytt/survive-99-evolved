local M = { current = nil }
function M.Set(omen) M.current = omen end
function M.Clear() M.current = nil end
function M.Get() return M.current end
function M.Is(name) return M.current == name end
return M
