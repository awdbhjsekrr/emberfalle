local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedCore = ReplicatedStorage:WaitForChild("sharedcore")

local Log = require(SharedCore.log)

local function init()
	Log.debug("Hello world, from client!")
	require(script.guihandler)
end

return {
	init = init,
}
