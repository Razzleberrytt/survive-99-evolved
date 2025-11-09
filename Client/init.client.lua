local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Ensure Shared folder reference
local Shared = ReplicatedStorage:WaitForChild("Shared")

local InputSystem = require(script.Parent.Systems.InputSystem)
local UISystem = require(script.Parent.Systems.UIPresentationSystem)
local Prediction = require(script.Parent.Systems.PredictionSystem)

InputSystem.Start()
UISystem.Start()
Prediction.Start()
