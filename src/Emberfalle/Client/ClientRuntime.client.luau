_G.__DEV__ = game:GetService("RunService"):IsStudio()

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = script.Parent
local Common = ReplicatedStorage.Common

local Controllers = Client.Controllers

local Log = require(Common.Log)
local ReplicaConnector = require(Client.ReplicaConnector)
local UIController = require(Controllers.UIController)

local localPlayer = Players.LocalPlayer

local function init()
	ReplicaConnector.Start()
	UIController.Start()
end

local function newPlayerCheck()
	local profile = ReplicaConnector.getProfile(localPlayer)
	if profile.Data.account.analytics.charactersCreated <= 0 then
		Log.debug(`{localPlayer} is a new player!`)
	end
end

local function Start()
	Log.debug("Hello world, from client!")
	init()
	newPlayerCheck()
end

Start()
