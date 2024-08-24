--!strict

--[[
	Server side entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ProfileManager = require(ServerStorage.Source.PlayerData.ProfileManager)
local CharacterSpawner = require(ReplicatedStorage.Source.CharacterSpawner)
local CinematicCamera = require(ReplicatedStorage.Source.CinematicCamera)
local Network = require(ReplicatedStorage.Source.Network)
local Collisions = require(ReplicatedStorage.Source.Collisions)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

Network.startServer()
ProfileManager.start()
Collisions.start()
CinematicCamera.startServer()

local function serverStartup()
	-- Move any guis to custom StarterGui folder to load them without needing to load character first.
	for _, gui in ipairs(game:GetService("StarterGui"):GetChildren()) do
		gui.Parent = ReplicatedStorage.StarterGui
	end
end

local function onPlayerAdded(newPlayer: Player)
	--CharacterSpawner.startRespawnLoop(newPlayer)
	--newPlayer.ReplicationFocus = Workspace:WaitForChild("Camera")
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)

serverStartup()
