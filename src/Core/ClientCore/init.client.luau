--[[ CLIENT RUNTIME HANDLER
	This script handles the client actions required for every place in the experience.
	Require and setup all core client modules before running this place's client scripts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedCore = ReplicatedStorage:WaitForChild("sharedcore")

local Client = require(script.Parent.client)
local ReplicaConnector = require(SharedCore.replicaconnector)

ReplicaConnector.init()

Client.init()
