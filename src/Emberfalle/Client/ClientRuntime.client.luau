_G.__DEV__ = game:GetService("RunService"):IsStudio()

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = script.Parent
local Common = ReplicatedStorage.Common

local Controllers = Client.Controllers

local Log = require(Common.Core.Log)
local ReplicaConnector = require(Client.Core.ReplicaConnector)
local UIController = require(Controllers.UIController)

local function init()
	ReplicaConnector.Start()
	UIController.Start()
end

local function Start()
	Log.debug("Hello world, from client!")
	init()
end

Start()
