--!strict

--[[
	Controls the initial loading screen on player join.
]]

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")

local MIN_RUN_TIME = 5

local LoadingScreen = {}

local gui = ReplicatedFirst.Instances.LoadingGui

function LoadingScreen.enable()
	gui.Parent = Players.LocalPlayer.PlayerGui
	if not _G.__DEV__ then
		task.wait(MIN_RUN_TIME)
	end
end

function LoadingScreen.disable()
	gui.Parent = ReplicatedFirst.Instances
end

return LoadingScreen
