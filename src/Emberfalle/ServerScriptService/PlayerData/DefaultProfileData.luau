--!strict

--[[
    Default profile for new players.
]]

local ProfileTemplate = {
	account = {
		analytics = {
			timePlayed = 0,
			charactersCreated = 0,
		},
		trackers = {},
		achievements = {},
	},
	characters = {},
}

return ProfileTemplate
