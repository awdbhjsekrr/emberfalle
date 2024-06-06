local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CommonCore = ReplicatedStorage.CommonCore
local Controllers = script.Controllers

local Log = require(CommonCore.Log)

local function init()
	Log.debug("Hello world, from client!")
	require(Controllers.UIController)
end

return {
	init = init,
}
