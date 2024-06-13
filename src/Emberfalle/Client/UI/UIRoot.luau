local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local Components = script.Parent.Components

local React = require(Packages.react)

local ScreenGui = require(Components.ScreenGui)

local e = React.createElement

local function myTestFrame()
	return e("TextLabel", {
		key = "Text",
	}, {})
end

local function UIRoot()
	return e(ScreenGui, {
		key = "UIRoot",
	}, { e(myTestFrame) })
end

return UIRoot
