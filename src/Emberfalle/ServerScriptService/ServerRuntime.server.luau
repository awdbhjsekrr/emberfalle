--!strict

--[[
	Server side entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileManager = require(ServerScriptService.Source.PlayerData.ProfileManager)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

ProfileManager.start()

local function onPlayerAdded(newPlayer: Player)
	local profile = ProfileManager.get(newPlayer)
	print("got", profile)
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)
