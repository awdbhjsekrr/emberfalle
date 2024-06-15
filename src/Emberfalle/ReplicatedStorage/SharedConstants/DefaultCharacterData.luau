--!strict

--[[
    Default template for a newly created character.
]]

type Classes = "warrior" | "ranger" | "cleric" | "rogue" | "mage" | "warlock"
type Race = "human" | "undead" | "orc"

export type CharacterData = {
	id: number,
	analytics: {
		timePlayed: number,
	},
	trackers: {},
	class: Classes,
	subclass: string | false,
	inventory: {},
	storage: {},
	maxStorage: number,
	talents: {},
	talentPoints: number,
	experience: number,
	skillExperience: {
		fishing: number,
		cooking: number,
		herbalism: number,
		alchemy: number,
	},
	appearance: {
		race: Race,
	},
}

local NewCharacterData: CharacterData = {}

return NewCharacterData
