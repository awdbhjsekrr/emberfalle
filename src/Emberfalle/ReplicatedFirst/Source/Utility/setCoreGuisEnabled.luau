--!strict

--[[
	Enables or disables the core guis
]]

local StarterGui = game:GetService("StarterGui")

local function setCoreGuisEnabled(enabled: boolean)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, enabled)
end

return setCoreGuisEnabled
