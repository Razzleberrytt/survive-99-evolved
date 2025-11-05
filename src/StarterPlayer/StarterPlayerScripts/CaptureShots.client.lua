local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local cams = {
	CFrame.new(Vector3.new(0,45,-90), Vector3.new(0,10,0)),
	CFrame.new(Vector3.new(-110,35,60), Vector3.new(0,8,0)),
	CFrame.new(Vector3.new(90,30,40), Vector3.new(0,8,0)),
}

Players.LocalPlayer.Chatted:Connect(function(msg)
	if msg:lower():match("^/icon") then
		local cam = workspace.CurrentCamera; cam.CameraType = Enum.CameraType.Scriptable
		cam.CFrame = cams[1]
		print("[Capture] Set camera for ICON. Use Screenshot (File > Screenshot).")
	elseif msg:lower():match("^/thumbs") then
		local cam = workspace.CurrentCamera; cam.CameraType = Enum.CameraType.Scriptable
		for i, cf in ipairs(cams) do
			local t = TweenService:Create(cam, TweenInfo.new(2), {CFrame = cf})
			t:Play(); t.Completed:Wait()
			print(string.format("[Capture] Thumb %d ready — take a screenshot.", i))
		end
		cam.CameraType = Enum.CameraType.Custom
	end
end)
