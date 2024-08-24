--!strict

--[[
	Client sided entry point for all code in the experience.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")

_G.__DEV__ = RunService:IsStudio()

local LoadingScreen = require(ReplicatedFirst.Source.LoadingScreen)

local waitForGameLoaded = require(ReplicatedFirst.Source.Utility.waitForGameLoaded)
local setCoreGuisEnabled = require(ReplicatedFirst.Source.Utility.setCoreGuisEnabled)

local localPlayer = Players.LocalPlayer

local function preGameLoadTasksAsync()
	setCoreGuisEnabled(false)
	LoadingScreen.enable()
end

local function postGameLoadTasksAsync()
	for _, gui in ipairs(ReplicatedStorage.StarterGui:GetChildren()) do
		local newGui = gui:Clone()
		newGui.Parent = localPlayer.PlayerGui
	end

	local ReplicaConnector = require(ReplicatedStorage.Source.ReplicaConnector)
	local Network = require(ReplicatedStorage.Source.Network)
	local CinematicCamera = require(ReplicatedStorage.Source.CinematicCamera)
	local Collisions = require(ReplicatedStorage.Source.Collisions)
	local CharacterSpawner = require(ReplicatedStorage.Source.CharacterSpawner)

	LoadingScreen.disable()
	Network.startClient()
	ReplicaConnector.start()
	CinematicCamera.startClient()
	CharacterSpawner.addCharacterAddedCallback(localPlayer, "SetCollisionGroup", function(character: Model)
		Collisions.setCollisionGroup(character, "PlayerCharacters")
	end)

	local profile = ReplicaConnector.getReplicaOfClassByTag("PlayerProfile", "Player", localPlayer)
	if #profile.Data.characters < 1 then
		CinematicCamera.playTrack("CharacterCreation", 0)
	end
end

preGameLoadTasksAsync()
waitForGameLoaded()
postGameLoadTasksAsync()
