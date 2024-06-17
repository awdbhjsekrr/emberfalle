--!strict

--[[
    Yields until the game is finished loading.
]]

local function waitForGameLoaded()
	if game:IsLoaded() then
		return
	end
	game.Loaded:Wait()
end

return waitForGameLoaded
