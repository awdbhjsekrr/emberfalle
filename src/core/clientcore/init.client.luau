local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedCore = ReplicatedStorage:WaitForChild("sharedcore")

local Client = require(script.Parent.client)
local ReplicaConnector = require(SharedCore.replicaconnector)

ReplicaConnector.init()

Client.init()
