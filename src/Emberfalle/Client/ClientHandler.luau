local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Client = script.Parent
local Common = ReplicatedStorage.Common

local Controllers = Client.Controllers

local Log = require(Common.Core.Log)

local function Start()
	Log.debug("Hello world, from client!")
	require(Controllers.UIController)
end

return {
	Start = Start,
}
