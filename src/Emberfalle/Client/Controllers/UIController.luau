local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Common = ReplicatedStorage.Common
local ClientRuntime = script.Parent.Parent

local React = require(Packages.react)
local ReactRoblox = require(Packages["react-roblox"])
local Log = require(Common.Log)
local UIRoot = require(ClientRuntime.UI.UIRoot)

local e = React.createElement

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer.PlayerGui

local UIController = {}

local function myTestFrame()
	return e("TextLabel", {
		key = "Text",
	}, {})
end

local function Start()
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal(e(UIRoot), playerGui))
	Log.debug("Initialized UI under", playerGui:GetFullName())
	root:render(ReactRoblox.createPortal(e(myTestFrame), playerGui))
end

UIController.Start = Start

return UIController
