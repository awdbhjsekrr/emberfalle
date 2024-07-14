--!strict

--[[
	Handles respawning of the player character on death.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local InstanceObjectLinker = require(ServerStorage.Source.InstanceObjectLinker)
local Signal = require(ReplicatedStorage.Source.Packages.signal)

local CharacterContainer = Instance.new("Folder")
CharacterContainer.Name = "Characters"
CharacterContainer.Parent = Workspace

local CharacterSpawner = {}
CharacterSpawner.diedConnectionsByPlayer = {} :: { [Player]: Signal.Connection }

function CharacterSpawner.startRespawnLoop(player: Player)
	local newCharacterLoadedWrapper = InstanceObjectLinker.getLinkedObject(player, "CharacterLoadedWrapper")
	local diedConnection
	diedConnection = newCharacterLoadedWrapper.died:Connect(function()
		if player:IsDescendantOf(Players) then
			task.wait(Players.RespawnTime)
			player:LoadCharacter()
		end
	end)
	CharacterSpawner.diedConnectionsByPlayer[player] = diedConnection
	player:LoadCharacter()
end

function CharacterSpawner.stopRespawnLoop(player: Player)
	local diedConnection = CharacterSpawner.diedConnectionsByPlayer[player]
	if diedConnection then
		diedConnection:Disconnect()
		CharacterSpawner.diedConnectionsByPlayer[player] = nil
	end
end

return CharacterSpawner
