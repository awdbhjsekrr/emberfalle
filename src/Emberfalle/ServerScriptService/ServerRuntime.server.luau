--!strict

--[[
	Server side entry point for all code in the experience.
]]

local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProfileManager = require(ServerStorage.Source.PlayerData.ProfileManager)
local Network = require(ReplicatedStorage.Source.Network)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

Network.startServer()
ProfileManager.start()

local function serverStartup()
	-- Move any guis to custom StarterGui folder to load them without needing to load character first.
	for _, gui in ipairs(game:GetService("StarterGui"):GetChildren()) do
		gui.Parent = ReplicatedStorage.StarterGui
	end
end

local function onPlayerAdded(newPlayer: Player)
	local data = ProfileManager.get(newPlayer)
	print("Got data", data)
end

safePlayerAdded(function(newPlayer: Player)
	onPlayerAdded(newPlayer)
end)

serverStartup()
