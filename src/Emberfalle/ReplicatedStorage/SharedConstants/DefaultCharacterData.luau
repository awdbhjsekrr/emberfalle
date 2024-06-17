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
	specialization = false :: string | false,
	talents = {},
	talentPoints = 0,
	appearance = {},
	equipment = {
		head = false :: string | false,
		shoulders = false :: string | false,
		torso = false :: string | false,
		legs = false :: string | false,
		feet = false :: string | false,
		hands = false :: string | false,
		back = false :: string | false,
		neck = false :: string | false,
		ring = false :: string | false,
	},
}

return DefaultCharacterData
