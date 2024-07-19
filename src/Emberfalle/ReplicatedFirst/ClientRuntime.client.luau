--!strict

--[[
	Client sided entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

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

	LoadingScreen.disable()
	Network.startClient()
	ReplicaConnector.start()

	local profile = ReplicaConnector.getReplicaOfClassByTag("PlayerProfile", "Player", localPlayer)
	assert(profile, "Could not fetch profile")
	print("Got", profile.Data)
end

preGameLoadTasksAsync()
waitForGameLoaded()
postGameLoadTasksAsync()
