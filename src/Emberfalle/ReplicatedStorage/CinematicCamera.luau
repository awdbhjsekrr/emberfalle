--!strict

--[[
	Camera movement handler.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local localPlayer = Players.LocalPlayer
local camera = Workspace.CurrentCamera

local CinematicCamera = {}

function CinematicCamera._waitForCameraReady() end

function CinematicCamera.start() end

return CinematicCamera
