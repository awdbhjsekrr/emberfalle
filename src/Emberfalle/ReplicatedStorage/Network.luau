--!strict

local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()
local REMOTES_TO_CREATE = {
	EVENTS = {},
	FUNCTIONS = {},
}

local Network = {}
Network._serverStarted = false

local function createInstances(className: string, instanceNameList: { string }, parent: Instance)
	for _, instanceName in ipairs(instanceNameList) do
		local newInstance = Instance.new(className)
		newInstance.Name = instanceName
		newInstance.Parent = parent
	end
end

function Network._waitForServerStarted()
	if not Network._serverStarted then
		local eventsFolder = script:WaitForChild("Events")
		local functionsFolder = script:WaitForChild("Functions")
		for _, eventName in ipairs(REMOTES_TO_CREATE.EVENTS) do
			eventsFolder:WaitForChild(eventName)
		end
		for _, functionName in ipairs(REMOTES_TO_CREATE.EVENTS) do
			functionsFolder:WaitForChild(functionName)
		end
		Network._serverStarted = true
	end
end

function Network._getRemoteEvent(remoteEventName: string): RemoteEvent?
	Network._waitForServerStarted()
	return script.Events:FindFirstChild(remoteEventName)
end

function Network._getRemoteFunction(remoteFunctionName: string): RemoteFunction?
	Network._waitForServerStarted()
	return script.Functions:FindFirstChild(remoteFunctionName)
end

function Network.connectEvent(remoteEventName: string, callback: (...any) -> any)
	local remoteEvent = Network._getRemoteEvent(remoteEventName)
	assert(remoteEvent, `Cannot find remote event: {remoteEventName}`)
	if IS_SERVER then
		remoteEvent.OnServerEvent:Connect(callback)
	else
		remoteEvent.OnClientEvent:Connect(callback)
	end
end

function Network.bindFunction(remoteFunctionName: string, callback: (...any) -> any)
	local remoteFunction = Network._getRemoteFunction(remoteFunctionName)
	assert(remoteFunction, `Cannot find remote function: {remoteFunctionName}`)
	if IS_SERVER then
		remoteFunction.OnServerInvoke = callback
	else
		remoteFunction.OnClientInvoke = callback
	end
end

function Network.fireAllClients(remoteName: string, ...: any)
	assert(IS_SERVER, "Network.fireAllClients can only be called from server")
	Network._waitForServerStarted()
	local remoteEvent = script.Events:FindFirstChild(remoteName) :: RemoteEvent
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireAllClients(...)
end

function Network.startServer()
	assert(IS_SERVER, "Network.startServer can only be called from server")
	createInstances("Folder", { "Events", "Functions" }, script)
	createInstances("RemoteEvent", REMOTES_TO_CREATE.EVENTS, script.Events)
	createInstances("RemoteFunction", REMOTES_TO_CREATE.FUNCTIONS, script.Functions)
	Network._serverStarted = true
end

function Network.startClient()
	assert(IS_CLIENT, "Network.startClient can only be called from client")
	Network._waitForServerStarted()
end

return Network
