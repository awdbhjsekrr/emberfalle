--!strict

--[[
    Links objects to an instance and provides a getter function.
]]

local InstanceObjectLinker = {}
InstanceObjectLinker._instances = {} :: { [Instance]: { [string]: any } }

function InstanceObjectLinker.linkObject(instance: Instance, objectName: string, object: any)
	if not InstanceObjectLinker._instances[instance] then
		InstanceObjectLinker._instances[instance] = {}
	end
	InstanceObjectLinker._instances[instance][objectName] = object
end

function InstanceObjectLinker.getLinkedObject(instance: Instance, objectName: string)
	local instanceObjects = InstanceObjectLinker._instances[instance]
	return if instanceObjects then instanceObjects[objectName] else nil
end

return InstanceObjectLinker
