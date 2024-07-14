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

local localPlayer = Players.LocalPlayer

local function preGameLoadTasksAsync()
	LoadingScreen.enable()
end

local function postGameLoadTasksAsync()
	LoadingScreen.disable()
	local ReplicaConnector = require(ReplicatedStorage.Source.ReplicaConnector)
	local Network = require(ReplicatedStorage.Source.Network)
	Network.startClient()
	ReplicaConnector.start()
end

preGameLoadTasksAsync()
waitForGameLoaded()
postGameLoadTasksAsync()
