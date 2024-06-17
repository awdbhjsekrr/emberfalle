--!strict

--[[
	Default profile for new players.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DefaultCharacterData = require(ReplicatedStorage.Source.SharedConstants.DefaultCharacterData)

export type ClassType = {
	account: {
		analytics: {
			totalTimePlayed: number,
			totalCharactersCreated: number,
		},
		trackers: {},
		achievements: { [string]: number },
	},
	characters: { DefaultCharacterData.ClassType },
}

local DefaultProfileData: ClassType = {
	account = {
		analytics = {
			totalTimePlayed = 0,
			totalCharactersCreated = 0,
		},
		trackers = {},
		achievements = {},
	},
	characters = {},
}

return DefaultProfileData
