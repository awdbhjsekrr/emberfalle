--[[ LOG
	Centralized debugging module to only display in studio.
]]

local RunService = game:GetService("RunService")

local _IS_STUDIO = RunService:IsStudio()
local _DEV_MODE = _IS_STUDIO

local Log = {}

local function createLogFunction(levelName: string, logFn: (...string) -> (), printInDev: boolean)
	return function(...: any)
		if printInDev and not _DEV_MODE then
			return
		end
		local modulePath = debug.info(2, "s")
		local moduleName = modulePath:match("[^.]+$")
		logFn(`[{moduleName}] {levelName}:`, ...)
	end
end

Log.debug = createLogFunction("DEBUG", print, true)
Log.warn = createLogFunction("WARN", warn, true)

return Log
