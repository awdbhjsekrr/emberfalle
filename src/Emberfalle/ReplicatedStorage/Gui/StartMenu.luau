--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DataReplica = require(ReplicatedStorage.Source.DataReplica)

local localPlayer = Players.LocalPlayer

local gui = localPlayer.PlayerGui.StartMenu

local StartMenu = {}

function StartMenu.toggle()
	local data = DataReplica.get(localPlayer)
	gui.Frame.Play.Visible = data.account.lastPlayedCharacter ~= nil
	gui.Frame.LoadCharacter.Visible = #data.characters >= 2
	gui.Enabled = not gui.Enabled
	if not data.account.lastPlayedCharacter then
	end
end

return StartMenu
