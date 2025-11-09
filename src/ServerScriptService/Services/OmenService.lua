local CodexService = require(script.Parent.CodexService)

local M = { current = nil }
function M.Set(omen)
        M.current = omen
        CodexService.UpdateWorldState({ omen = omen })
        if omen then
                CodexService.Emit("OMEN_BEGIN", { omen = omen })
        end
end
function M.Clear()
        if M.current then
                CodexService.Emit("OMEN_CLEAR", { omen = M.current })
        end
        M.current = nil
        CodexService.UpdateWorldState({ omen = nil })
end
function M.Get() return M.current end
function M.Is(name) return M.current == name end
return M
