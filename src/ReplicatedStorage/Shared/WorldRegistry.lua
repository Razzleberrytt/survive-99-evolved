local M = { _world = nil }
function M.set(world) M._world = world end
function M.get() return M._world end
return M
