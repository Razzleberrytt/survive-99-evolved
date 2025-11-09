local Localization = {}
local defaultLocale = require(script.en)

local function resolveKey(tbl, key)
    local current = tbl
    for _, part in ipairs(string.split(key, ".")) do
        if typeof(current) ~= "table" then
            return nil
        end
        current = current[part]
    end
    return current
end

function Localization.get(key)
    if typeof(key) ~= "string" then
        return key
    end
    local value = resolveKey(defaultLocale, key)
    if value == nil then
        return key
    end
    if typeof(value) == "string" then
        return value
    end
    return key
end

function Localization.getDictionary()
    return defaultLocale
end

return Localization
