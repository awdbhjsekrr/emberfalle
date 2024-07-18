--!strict

--[[
	Server side entry point for all code in the experience.
]]

_G.__DEV__ = game:GetService("RunService"):IsStudio()

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local ProfileManager = require(ServerStorage.Source.PlayerData.ProfileManager)
local CharacterSpawner = require(ServerStorage.Source.CharacterSpawner)
local Network = require(ReplicatedStorage.Source.Network)
local Collisions = require(ReplicatedStorage.Source.Collisions)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

Network.startServer()
ProfileManager.start()
Collisions.start()

for _, gui in ipairs(game:GetService("StarterGui"):GetChildren()) do
	gui.Parent = ReplicatedStorage.StarterGui
end

local function onPlayerAdded(newPlayer: Player)
	CharacterSpawner.addCharacterAddedCallback(newPlayer, "SetCollisionGroup", function(character: Model)
		Collisions.setCollisionGroup(character, "PlayerCharacters")
	end)
	CharacterSpawner.startRespawnLoop(newPlayer)
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)

Collisions.setCollisionGroup(Workspace.CharacterCreationZone.CharacterCreationRig, "NonPlayerCharacters")
