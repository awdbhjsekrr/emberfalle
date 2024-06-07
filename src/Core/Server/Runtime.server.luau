--[[ SERVER RUNTIME HANDLER
	This script handles the server actions required for every place in the experience.
	Require and setup all core server modules before running this place's server scripts.
]]

local Players = game:GetService("Players")

local Server = script.Parent.Parent

local UserData = require(Server.Core.UserData)
local ServerHandler = require(Server.ServerHandler)

local function playerAdded(player: Player)
	UserData.increment(player, { "joinCount" }, 1)
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)

ServerHandler.Start()
