local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local Red = require(Packages.red)

return Red.Event("TestEvent", function(num: unknown)
	assert(typeof(num) == "number", "num must be a number!")
	return num
end)
