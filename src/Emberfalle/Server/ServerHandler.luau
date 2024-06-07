local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonCore = ReplicatedStorage:WaitForChild("CommonCore")

local Log = require(CommonCore.Log)

local function Start()
	Log.debug("Hello world, from server!")
end

return {
	Start = Start,
}
