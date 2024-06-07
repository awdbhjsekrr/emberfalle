--[[ CLIENT RUNTIME HANDLER
	This script handles the client actions required for every place in the experience.
	Require and setup all core client modules before running this place's client scripts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = script.Parent.Parent
local Common = ReplicatedStorage:WaitForChild("Common")

local ClientHandler = require(Client.ClientHandler)
local ReplicaConnector = require(Common.Core.ReplicaConnector)

ReplicaConnector.Start()
ClientHandler.Start()
