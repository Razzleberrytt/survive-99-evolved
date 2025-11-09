local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = require(ReplicatedStorage.Shared.Net.Remotes)

local InputSystem = {}

function InputSystem.Start()
    -- Example: tap anywhere to send a dummy attack
    UserInputService.TouchTap:Connect(function(pos, processed)
        if processed then return end
        local ev = Remotes.get("Input_Attack")
        if ev then ev:FireServer({ weaponId = "melee", t = time() }) end
    end)
end

return InputSystem
