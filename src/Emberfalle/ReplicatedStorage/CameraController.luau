--!strict

--[[
	Utilities for controlling the player's camera.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local cameraLocations = workspace:FindFirstChild("CameraLocations") or ReplicatedStorage.CameraLocations
cameraLocations.Parent = ReplicatedStorage

local camera = workspace.CurrentCamera

local CameraController = {}
CameraController.locations = cameraLocations

local function fixCameraType()
	if camera.CameraType ~= Enum.CameraType.Scriptable then
		repeat
			camera.CameraType = Enum.CameraType.Scriptable
			if camera.CameraType == Enum.CameraType.Scriptable then
				return
			end
			task.wait()
		until camera.CameraType == Enum.CameraType.Scriptable
	end
end

function CameraController.tweenTo(folder: Folder, t: number)
	fixCameraType()
	local newLocation = folder:WaitForChild("1")
	if not newLocation:IsA("BasePart") then
		return
	end
	local tweenInfo = TweenInfo.new(t)
	TweenService:Create(camera, tweenInfo, {
		CFrame = newLocation.CFrame,
	}):Play()
end

function CameraController.moveTo(folder: Folder)
	CameraController.tweenTo(folder, 0)
end

return CameraController
