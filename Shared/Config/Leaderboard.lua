return {
    Reset = { day = "Mon", time = "00:00", tz = "UTC" },
    weekKey = function(nowUtc)
        local wk = tonumber(os.date("!%V", nowUtc)) or 1
        local yr = tonumber(os.date("!%G", nowUtc)) or tonumber(os.date("!*t", nowUtc).year)
        return string.format("%04d-W%02d", yr, wk)
    end,
}
