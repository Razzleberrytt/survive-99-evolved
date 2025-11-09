local DataService = require(script.Parent.Parent.Services.DataService)

local Autosave = {}
Autosave._running = false

function Autosave.Start(period)
    if Autosave._running then return end
    Autosave._running = true
    period = period or 60
    task.spawn(function()
        while Autosave._running do
            local jitter = math.random(0, 10)
            task.wait(period + jitter)
            DataService:IterProfiles(function(player, profile)
                if profile._mock then return end
                if profile.Save then
                    pcall(function() profile:Save() end)
                elseif profile.SaveAsync then
                    pcall(function() profile:SaveAsync() end)
                end
            end)
        end
    end)
end

function Autosave.Stop()
    Autosave._running = false
end

return Autosave
