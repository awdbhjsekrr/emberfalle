local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("Packages")
local CommonCore = ReplicatedStorage:WaitForChild("CommonCore")

local Log = require(CommonCore.Log)
local React = require(Packages.react)
local ReactRoblox = require(Packages["react-roblox"])

local localPlayer = Players.LocalPlayer

local e = React.createElement

local function myTestFrame()
	return e("Frame", {
		Size = UDim2.new(0, 100, 0, 100),
	})
end

local handle = Instance.new("ScreenGui")
handle.Parent = localPlayer.PlayerGui

local root = ReactRoblox.createRoot(handle)
root:render(e(myTestFrame, {}, {}))

return {}
