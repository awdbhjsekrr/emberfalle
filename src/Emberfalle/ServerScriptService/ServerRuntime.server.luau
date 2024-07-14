--!strict

--[[
	Server side entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local InstanceObjectLinker = require(ServerStorage.Source.InstanceObjectLinker)
local ProfileManager = require(ServerStorage.Source.PlayerData.ProfileManager)
local CharacterSpawner = require(ServerStorage.Source.CharacterSpawner)
local CharacterLoadedWrapper = require(ReplicatedStorage.Source.CharacterLoadedWrapper)
local Network = require(ReplicatedStorage.Source.Network)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

Network.startServer()
ProfileManager.start()

local function onPlayerAdded(newPlayer: Player)
	ProfileManager.increment(newPlayer, { "account", "analytics", "totalPlacesJoined" }, 1)
	local profile = ProfileManager.get(newPlayer)
	InstanceObjectLinker.linkObject(newPlayer, "CharacterLoadedWrapper", CharacterLoadedWrapper.new(newPlayer))
	CharacterSpawner.startRespawnLoop(newPlayer)
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)
