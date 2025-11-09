local function check(spec, payload)
    if type(payload) ~= "table" then return false, "payload-not-table" end
    for k, typ in pairs(spec) do
        local v = payload[k]
        if typeof(v) ~= typ then
            return false, string.format("field-%s-expected-%s-got-%s", tostring(k), tostring(typ), typeof(v))
        end
    end
    return true
end
return check
