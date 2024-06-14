--!strict

local function waitForGameLoaded()
	if game:IsLoaded() then
		return
	end
	game.Loaded:Wait()
end

return waitForGameLoaded
