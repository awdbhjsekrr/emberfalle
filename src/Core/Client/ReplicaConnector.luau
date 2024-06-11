--[[ REPLICA CONNECTOR
	Centralized client replica handler.
]]
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Common = ReplicatedStorage.Common
local Packages = ReplicatedStorage.Packages

local Log = require(Common.Core.Log)
local ReplicaController = require(Packages.replicacontroller)

local REQUEST_TIMEOUT = 10

local classListeners = {
	"PlayerProfile",
}

local replicas = {}

local ReplicaConnector = {}

local function waitForReplicasOfClass(className: string): {}?
	if replicas[className] == nil then
		local startTick = tick()
		repeat
			if tick() - startTick > REQUEST_TIMEOUT then
				Log.warn("Timed out waiting for replica of class: " .. className)
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

local function getProfile(player: Player)
	return getReplicaOfClassByTag("PlayerProfile", "Player", player)
end

local function Start()
	for _, className in ipairs(classListeners) do
		if replicas[className] == nil then
			replicas[className] = {}
		end
		ReplicaController.ReplicaOfClassCreated(className, function(replica)
			table.insert(replicas[className], replica)
			Log.debug(`{className} replica received: {replica:Identify()}`)
		end)
	end
	ReplicaController.RequestData()
end

ReplicaConnector.Start = Start
ReplicaConnector.getReplicaOfClassByTag = getReplicaOfClassByTag
ReplicaConnector.waitForReplicasOfClass = waitForReplicasOfClass
ReplicaConnector.getProfile = getProfile

return ReplicaConnector
