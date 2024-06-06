local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SharedCore = ReplicatedStorage.sharedcore
local Controllers = script.controllers

local Log = require(SharedCore.log)

local function init()
	Log.debug("Hello world, from client!")
	require(Controllers.uicontroller)
end

return {
	init = init,
}
