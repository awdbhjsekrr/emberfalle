--!strict

--[[
	Server side entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileManager = require(ServerStorage.Source.PlayerData.ProfileManager)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

ProfileManager.start()

local function onPlayerAdded(newPlayer: Player)
	local profile = ProfileManager.get(newPlayer)
	print("got", profile)
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)
