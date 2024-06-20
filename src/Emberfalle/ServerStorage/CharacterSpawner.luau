--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

local InstanceObjectLinker = require(ServerStorage.Source.InstanceObjectLinker)
local CharacterLoadedWrapper = require(ReplicatedStorage.Source.CharacterLoadedWrapper)
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
		task.wait(Players.RespawnTime)
		player:LoadCharacter()
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
