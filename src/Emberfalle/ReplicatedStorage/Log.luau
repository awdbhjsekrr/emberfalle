--[[ LOG
	Centralized debugging module to only display in studio.
]]

local Log = {}

local function createLogFunction(levelName: string?, logFn: (...string) -> (), printInDev: boolean)
	return function(...: any)
		if printInDev and not _G.__DEV__ then
			return
		end
		local modulePath = debug.info(2, "s")
		local moduleName = modulePath:match("[^.]+$")
		logFn(`[{moduleName}]{levelName and " " .. levelName or ""}:`, ...)
	end
end

Log.debug = createLogFunction(nil, print, true)
Log.warn = createLogFunction("WARN", warn, true)

return Log
