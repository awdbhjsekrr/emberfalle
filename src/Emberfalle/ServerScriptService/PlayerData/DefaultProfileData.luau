--!strict

--[[
	Default profile for new players.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultCharacterData = require(ReplicatedStorage.Source.SharedConstants.DefaultCharacterData)

local DefaultProfileData = {
	account = {
		analytics = {
			totalTimePlayed = 0,
			numCharactersCreated = 0,
		},
		trackers = {},
		achievements = {} :: { [string]: number },
	},
	characters = {},
}

return DefaultProfileData
