--[[ REPLICA CONNECTOR
	Centralized client replica handler.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Packages = ReplicatedStorage:WaitForChild("packages")

local ReplicaController = require(Packages.replicacontroller)

local REQUEST_TIMEOUT = 10

local classListeners = {
	"PlayerProfile",
}

local replicas = {}

local function waitForReplicasOfClass(className: string): {}?
	if replicas[className] == nil then
		local startTick = tick()
		repeat
			if tick() - startTick > REQUEST_TIMEOUT then
				error("Timed out waiting for replica of class: " .. className)
				return nil
			end
			task.wait()
		until replicas[className] ~= nil
	end
	return replicas[className]
end

local function getReplicaOfClassByTag(className: string, tagName: string, tagValue: any)
	local replicasOfClass = waitForReplicasOfClass(className)
	if not replicasOfClass then
		return
	end
	local startTick = tick()
	repeat
		for _, replica in ipairs(replicasOfClass) do
			if replica.Tags[tagName] == tagValue then
				return replica
			end
		end
		task.wait()
	until tick() - startTick > REQUEST_TIMEOUT
	return
end

local function getReplicaOfClass(className: string)
	return waitForReplicasOfClass(className)
end

local function init()
	for _, className in ipairs(classListeners) do
		if replicas[className] == nil then
			replicas[className] = {}
		end
		ReplicaController.ReplicaOfClassCreated(className, function(replica)
			table.insert(replicas[className], replica)
			print(className, " replica received:", replica:Identify())
		end)
	end
	ReplicaController.RequestData()
end

return {
	init = init,
	getReplicaOfClassByTag = getReplicaOfClassByTag,
	getReplicaOfClass = getReplicaOfClass,
}
