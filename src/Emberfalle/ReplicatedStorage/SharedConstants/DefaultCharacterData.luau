--!strict

--[[
	Default template for a newly created character.
]]

type CharacterClass = "warrior" | "archer" | "mage"
type CharacterRace = "human"

export type ClassType = {
	id: number,
	analytics: {
		totalTimePlayed: number,
	},
	inventory: {},
	storage: {},
	class: CharacterClass,
	race: CharacterRace,
	specialization: string | false,
	talents: {},
	talentPoints: number,
	appearance: {},
	equipment: {
		head: string | false,
		shoulders: string | false,
		torso: string | false,
		legs: string | false,
		feet: string | false,
		hands: string | false,
		back: string | false,
		neck: string | false,
		ring: string | false,
	},
}

local DefaultCharacterData: ClassType = {
	id = 0,
	analytics = {
		totalTimePlayed = 0,
	},
	inventory = {},
	storage = {},
	class = "warrior",
	race = "human",
	specialization = false,
	talents = {},
	talentPoints = 0,
	appearance = {},
	equipment = {
		head = false,
		shoulders = false,
		torso = false,
		legs = false,
		feet = false,
		hands = false,
		back = false,
		neck = false,
		ring = false,
	},
}

return DefaultCharacterData
