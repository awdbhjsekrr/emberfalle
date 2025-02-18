--!strict

--[[
	Client sided entry point for all code in the experience.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local LoadingScreen = require(ReplicatedFirst.Source.LoadingScreen)

local waitForGameLoaded = require(ReplicatedFirst.Source.Utility.waitForGameLoaded)
local setCoreGuisEnabled = require(ReplicatedFirst.Source.Utility.setCoreGuisEnabled)

local localPlayer = Players.LocalPlayer

local function preGameLoadTasks()
	setCoreGuisEnabled(false)
	LoadingScreen.enable()
end

local function postGameLoadTasks()
	local ReplicationFocus = require(ReplicatedStorage.Source.ReplicationFocus)
	local DataReplica = require(ReplicatedStorage.Source.DataReplica)

	for _, gui in ipairs(ReplicatedStorage.StarterGui:GetChildren()) do
		local newGui = gui:Clone()
		newGui.Parent = localPlayer.PlayerGui
	end

	DataReplica.startClient()
	ReplicationFocus.startClient()

	LoadingScreen.disable()
	setCoreGuisEnabled(true)
end

preGameLoadTasks()
waitForGameLoaded()
postGameLoadTasks()
