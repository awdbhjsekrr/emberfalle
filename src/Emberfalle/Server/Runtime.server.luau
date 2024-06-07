local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Server = script.Parent
local Common = ReplicatedStorage.Common

local UserData = require(Server.Core.UserData)
local Log = require(Common.Core.Log)

local function playerAdded(player: Player)
	UserData.increment(player, { "joinCount" }, 1)
end

local function Start()
	Log.debug("Hello world, from server!")
	Players.PlayerAdded:Connect(playerAdded)
end

Start()
