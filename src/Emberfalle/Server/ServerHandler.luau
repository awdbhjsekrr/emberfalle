local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage.Common

local Log = require(Common.Core.Log)

local function Start()
	Log.debug("Hello world, from server!")
end

return {
	Start = Start,
}
