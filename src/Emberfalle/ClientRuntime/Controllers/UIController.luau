local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage.Packages
local CommonCore = ReplicatedStorage.CommonCore
local ClientRuntime = script.Parent.Parent

local React = require(Packages.react)
local ReactRoblox = require(Packages["react-roblox"])

local Log = require(CommonCore.Log)

local UIRoot = require(ClientRuntime.UI.UIRoot)

local e = React.createElement

local function start()
	local container = Players.LocalPlayer:FindFirstChildOfClass("PlayerGui")

	-- Note: `createRoot` takes control of its container and will destroy any
	--  existing children. To work around this, we use a folder as the container
	--  and portal the UI to where we actually want it.
	--
	--  To be honest, I have no idea why React behaves this way.
	local root = ReactRoblox.createRoot(Instance.new("Folder"))
	root:render(ReactRoblox.createPortal(e(UIRoot), container))

	Log.debug("Initialized UI under", container:GetFullName())
end

start()

return nil
