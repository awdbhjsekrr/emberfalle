--!strict

--[[
	Waits for a child to be added with the specified ClassName
]]

local function waitForChildOfClass(instance: Instance, className: string)
	local child = instance:FindFirstChildOfClass(className)
	while not child do
		instance.ChildAdded:Wait()
		child = instance:FindFirstChildOfClass(className)
	end
	return child
end

return waitForChildOfClass
