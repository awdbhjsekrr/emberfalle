local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonCore = ReplicatedStorage:WaitForChild("CommonCore")

local Log = require(CommonCore.Log)

local function start()
	Log.debug("Hello world, from server!")
end

return {
	start = start,
}
