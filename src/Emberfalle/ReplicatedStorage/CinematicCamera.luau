--!strict

--[[
	Camera movement handler.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

if Workspace:FindFirstChild("CameraLocations") then
	Workspace.CameraLocations.Parent = ReplicatedStorage
end

local CinematicCamera = {}

local currentTween

function CinematicCamera._waitForCameraReady() end

function CinematicCamera.returnToDefault() end

function CinematicCamera.playTrack(trackName: string, t: number, transitionTo: boolean?, transitionSpeed: number?)
	local track = ReplicatedStorage.CameraLocations:FindFirstChild(trackName)
	assert(track, `Could not find camera track: {trackName}`)
	local trackCount = #track:GetChildren()
	local timeBetweenTweens = trackCount - 1 / t
	for i = 1, trackCount do
		local nextLocation = track[tostring(i)]
		assert(nextLocation, `Camera track {trackName} missing location: {i}`)
		if i == 1 then
			if transitionTo then
				local transitionToTweenInfo = TweenInfo.new(transitionSpeed or 1)
				local transitionToTween = TweenService:Create(camera, transitionToTweenInfo, {
					CFrame = nextLocation.CFrame,
				})
				transitionToTween:Play()
				task.wait(transitionSpeed or 1)
			else
				camera.CFrame = nextLocation.CFrame
			end
		else
			local transitionTweenInfo = TweenInfo.new(timeBetweenTweens)
			local transitionTween = TweenService:Create(camera, transitionTweenInfo, {
				CFrame = nextLocation.CFrame,
			})
			transitionTween:Play()
			transitionTween.Completed:Wait()
		end
	end
end

return CinematicCamera
