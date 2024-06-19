--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local Signal = require(ReplicatedStorage.Source.Packages.signal)

local CharacterSpawner = {}
CharacterSpawner.diedConnectionsByPlayer = {} :: { [Player]: Signal.Signal<nil> }

function CharacterSpawner.startRespawnLoop(player: Player)
	CharacterSpawner.diedConnectionsByPlayer[player] = Signal.new()
end
