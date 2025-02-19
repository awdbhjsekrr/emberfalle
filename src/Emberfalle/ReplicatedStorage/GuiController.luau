--!strict

--[[
	Controls the Guis.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local guiModules = ReplicatedStorage.Source.Gui

local GuiController = {}

function GuiController.startClient()
	for _, gui: ScreenGui in pairs(ReplicatedStorage.StarterGui:GetChildren()) do
		local newGui = gui:Clone()
		newGui.Parent = Players.LocalPlayer.PlayerGui
	end
	GuiController.StartMenu = require(guiModules.StartMenu)
end

return GuiController
