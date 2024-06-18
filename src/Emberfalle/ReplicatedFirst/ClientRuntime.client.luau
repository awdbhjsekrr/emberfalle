--!strict

--[[
	Client sided entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local waitForGameLoaded = require(ReplicatedFirst.Source.Utility.waitForGameLoaded)

local localPlayer = Players.LocalPlayer

local function preGameLoadTasksAsync()
	local LoadingScreen = require(ReplicatedFirst.Source.LoadingScreen)
end

local function postGameLoadTasksAsync() end

preGameLoadTasksAsync()
waitForGameLoaded()
postGameLoadTasksAsync()
