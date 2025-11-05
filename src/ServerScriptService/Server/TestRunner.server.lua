--!strict

local RunService = game:GetService("RunService")

if not RunService:IsStudio() then
	return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TestEZ = require(ReplicatedStorage.Packages.testez)

local testsFolder = script.Parent:FindFirstChild("Tests")
if testsFolder then
	local results = TestEZ.TestBootstrap:run(
		{ testsFolder }
	)
	print("[TestEZ] Results", results.success and "OK" or "FAILED")
else
	warn("[TestEZ] No tests folder found")
end
