--!strict

--[[
	Server side entry point for all code in the experience.
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileManager = require(ServerStorage.Source.ProfileManager)
local ReplicationFocus = require(ReplicatedStorage.Source.ReplicationFocus)
local CharacterSpawner = require(ServerStorage.Source.CharacterSpawner)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

ProfileManager.start()
ReplicationFocus.startServer()

local function serverStartup()
	-- Move any guis to custom StarterGui folder to load them without needing to load character first.
	for _, gui in ipairs(game:GetService("StarterGui"):GetChildren()) do
		gui.Parent = ReplicatedStorage.StarterGui
	end
end

local function onPlayerAdded(player: Player) end

safePlayerAdded(function(player: Player)
	onPlayerAdded(player)
end)

serverStartup()
