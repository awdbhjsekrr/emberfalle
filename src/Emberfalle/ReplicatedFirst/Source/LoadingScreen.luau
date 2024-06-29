--!strict

--[[
	Controls the initial loading screen on player join.
]]

local MIN_RUN_TIME = 5

local LoadingScreen = {}

function LoadingScreen.enable()
	print("Loading screen enabled!")
end

function LoadingScreen.disable()
	print("Loading screen disabled!")
end

return LoadingScreen
