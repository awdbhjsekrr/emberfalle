local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages

local React = require(Packages.react)

local e = React.createElement

local function ScreenGui(props)
	return e("ScreenGui", {
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		ResetOnSpawn = false,
	}, props.children)
end

return ScreenGui
