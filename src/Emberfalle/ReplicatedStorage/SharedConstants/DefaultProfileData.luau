--!strict

--[[
	Default profile for new players.
]]

local DefaultCharacterData = require("./DefaultCharacterData")

export type ClassType = {
	account: {
		analytics: {
			totalPlacesJoined: number,
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
			totalPlacesJoined = 0,
			totalTimePlayed = 0,
			totalCharactersCreated = 0,
		},
		trackers = {},
		achievements = {},
	},
	characters = {},
}

return DefaultProfileData
