--[[ CLIENT RUNTIME HANDLER
	This script handles the client actions required for every place in the experience.
	Require and setup all core client modules before running this place's client scripts.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonCore = ReplicatedStorage:WaitForChild("CommonCore")

local Client = require(script.Parent.Client)
local ReplicaConnector = require(CommonCore.ReplicaConnector)

local function Start()
	ReplicaConnector.Start()
	ClientRuntime.start()
end

Start()
