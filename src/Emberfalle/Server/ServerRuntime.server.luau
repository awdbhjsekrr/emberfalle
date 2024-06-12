_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = script.Parent
local Common = ReplicatedStorage.Common

local ProfileManager = require(Server.Core.ProfileManager)
local Log = require(Common.Core.Log)

local function playerAdded(player: Player)
	Log.debug(`New player joining: {player}`)
	local profile = ProfileManager.get(player)
	if not profile.character then
		Log.debug(`{player} is a new player!`)
	end
end

local function Start()
	Log.debug("Hello world, from server!")
	Players.PlayerAdded:Connect(playerAdded)
end

Start()
