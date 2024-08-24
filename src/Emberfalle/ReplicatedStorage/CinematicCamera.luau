--!strict

--[[
	Camera movement handler.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Network = require(ReplicatedStorage.Source.Network)

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

if Workspace:FindFirstChild("CameraTracks") then
	Workspace.CameraTracks.Parent = ReplicatedStorage
end

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

local CinematicCamera = {}
CinematicCamera._serverStarted = false
CinematicCamera._clientStarted = false
CinematicCamera._replicatedCamerasByPlayer = {}

local currentTween

function CinematicCamera._waitForCameraReady() end

function CinematicCamera.returnToDefault()
	CinematicCamera.setCameraType(Enum.CameraType.Attach)
	camera.CameraSubject = localPlayer.Character
end

function CinematicCamera.setCameraType(cameraType: Enum.CameraType)
	camera.CameraType = cameraType
end

function CinematicCamera.playTrack(trackName: string, t: number, transitionTo: boolean?, transitionSpeed: number?)
	CinematicCamera.setCameraType(Enum.CameraType.Scriptable)
	local cam = Network.invokeServer("AddReplicateCamera")
	task.spawn(function()
		while true do
			print(cam.CFrame)
		end
	end)
	local track = ReplicatedStorage.CameraTracks:FindFirstChild(trackName)
	assert(track, `Could not find camera track: {trackName}`)
	local trackCount = #track:GetChildren()
	local timeBetweenTweens = trackCount - 1 / t
	for i = 1, trackCount do
		local nextLocation = track[tostring(i)]
		assert(nextLocation, `Camera track {trackName} missing location: {i}`)
		camera.CameraSubject = nextLocation
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

function CinematicCamera.startServer()
	assert(not CinematicCamera._serverStarted, "CinematicCamera._startServer has already been called")
	safePlayerAdded(function(newPlayer: Player)
		assert(
			not CinematicCamera._replicatedCamerasByPlayer[newPlayer],
			`{newPlayer.Name} already has a replicated camera`
		)
		local newReplicatedCamera = Instance.new("Part")
		newReplicatedCamera.Anchored = true
		newReplicatedCamera.CanCollide = true
		newReplicatedCamera.Transparency = 1
		CinematicCamera._replicatedCamerasByPlayer[newPlayer] = newReplicatedCamera
	end)
	Network.bindFunction("AddReplicateCamera", function(player: Player)
		local replicatedCamera = CinematicCamera._replicatedCamerasByPlayer[player]
		assert(replicatedCamera, `{player.Name} missing replicate camera`)
		replicatedCamera.Anchored = false
		replicatedCamera.Parent = Workspace
		replicatedCamera:SetNetworkOwner(player)
		player.ReplicationFocus = replicatedCamera
		print("returning", replicatedCamera)
		return replicatedCamera
	end)
	Network.connectEvent("RemoveReplicateCamera", function(player: Player)
		local replicatedCamera = CinematicCamera._replicatedCamerasByPlayer[player]
		assert(replicatedCamera, `{player.Name} missing replicate camera`)
		replicatedCamera.Anchored = true
		replicatedCamera.Parent = nil
		replicatedCamera:SetNetworkOwnershipAuto()
		if player.Character then
			player.ReplicationFocus = player.Character
		end
		return
	end)
end

function CinematicCamera.startClient()
	assert(not CinematicCamera._clientStarted, "CinematicCamera._startClient has already been called")
end

return CinematicCamera
