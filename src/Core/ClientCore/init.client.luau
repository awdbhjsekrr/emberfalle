--[[ CLIENT RUNTIME HANDLER
	This script handles the client actions required for every place in the experience.
	Require and setup all core client modules before running this place's client scripts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonCore = ReplicatedStorage:WaitForChild("CommonCore")

local ClientRuntime = require(script.Parent.ClientRuntime)
local ReplicaConnector = require(CommonCore.ReplicaConnector)

ReplicaConnector.start()
ClientRuntime.start()
