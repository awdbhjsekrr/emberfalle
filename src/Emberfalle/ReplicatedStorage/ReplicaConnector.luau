--!strict

--[[
	Centralized client replica manager.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ReplicaController = require(ReplicatedStorage.Source.Packages.replicacontroller)

local REQUEST_TIMEOUT = 10
local CLASS_LISTENERS = {
	"PlayerProfile",
}

local ReplicaConnector = {}
ReplicaConnector._replicas = {}

function ReplicaConnector.waitForReplicasOfClass(className: string)
	if ReplicaConnector._replicas[className] == nil then
		local startTick = tick()
		repeat
			if tick() - startTick > REQUEST_TIMEOUT then
				return nil
			end
			task.wait()
		until ReplicaConnector._replicas[className] ~= nil
	end
	return ReplicaConnector._replicas[className]
end

function ReplicaConnector.getReplicaOfClassByTag(className: string, tagName: string, tagValue: any): any
	local replicasOfClass = ReplicaConnector.waitForReplicasOfClass(className)
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

function ReplicaConnector.start()
	for _, className in ipairs(CLASS_LISTENERS) do
		if ReplicaConnector._replicas[className] == nil then
			ReplicaConnector._replicas[className] = {}
		end
		ReplicaController.ReplicaOfClassCreated(className, function(replica)
			table.insert(ReplicaConnector._replicas[className], replica)
		end)
	end
	ReplicaController.RequestData()
end

return ReplicaConnector
