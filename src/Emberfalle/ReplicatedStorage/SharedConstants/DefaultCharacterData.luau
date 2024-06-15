--!strict

--[[
    Default template for a newly created character.
]]

type ClassType = "warrior" | "archer" | "mage"
type RaceType = "human"

local DefaultCharacterData = {
	id = 0,
	analytics = {
		totalTimePlayed = 0,
	},
	inventory = {},
	storage = {},
	class = "warrior" :: ClassType,
	race = "human" :: RaceType,
}

return DefaultCharacterData
