--!strict

--[[
	Module used to centralize remotes.
]]

local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local REMOTES_TO_CREATE = {
	EVENTS = {
		"RemoteEvent"
	},
	FUNCTIONS = {
		"RemoteFunction"
	},
	UNRELIABLE_EVENTS = {
		"UnreliableRemoteEvent"
	},
}

local Network = {}

local function createInstances(className: string, instanceNameList: { string }, parent: Instance)
	for _, instanceName in ipairs(instanceNameList) do
		local newInstance = Instance.new(className)
		newInstance.Name = instanceName
		newInstance.Parent = parent
	end
end

function Network._getRemoteEvent(remoteEventName: string): RemoteEvent?
	return script.Events:FindFirstChild(remoteEventName) or script.UnreliableEvents:FindFirstChild(remoteEventName)
end

function Network._getRemoteFunction(remoteFunctionName: string): RemoteFunction?
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
	local remoteEvent = script.Events:FindFirstChild(remoteName) :: RemoteEvent
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireAllClients(...)
end

function Network.fireClient(remoteName: string, player: Player, ...: any)
	assert(IS_SERVER, "Network.fireAllClients can only be called from server")
	local remoteEvent = script.Events:FindFirstChild(remoteName) :: RemoteEvent
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireClient(player, ...)
end

function Network.fireServer(remoteName: string, ...: any)
	assert(IS_CLIENT, "Network.fireServer can only be called from client")
	local remoteEvent = script.Events:FindFirstChild(remoteName) :: RemoteEvent
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireServer(...)
end

function Network.invokeClient(remoteName: string, player: Player, ...: any)
	assert(IS_SERVER, "Network.invokeClient can only be called from server")
	local remoteFunction = script.Functions:FindFirstChild(remoteName) :: RemoteFunction
	assert(remoteFunction, `Could not find remote function: {remoteName}`)
	return remoteFunction:InvokeClient(player, ...)
end

function Network.invokeServer(remoteName: string, ...: any)
	assert(IS_CLIENT, "Network.invokeServer can only be called from client")
	local remoteFunction = script.Functions:FindFirstChild(remoteName) :: RemoteFunction
	assert(remoteFunction, `Could not find remote function: {remoteName}`)
	local val, resp = pcall(remoteFunction.InvokeServer, remoteFunction, ...)
	print("retutning", val, resp)
	return resp
end

function Network.startServer()
	assert(IS_SERVER, "Network.startServer can only be called from server")
	Network._serverStarted = true
	createInstances("Folder", { "Events", "Functions", "UnreliableEvents" }, script)
	createInstances("RemoteEvent", REMOTES_TO_CREATE.EVENTS, script.Events)
	createInstances("RemoteFunction", REMOTES_TO_CREATE.FUNCTIONS, script.Functions)
	createInstances("UnreliableRemoteEvent", REMOTES_TO_CREATE.UNRELIABLE_EVENTS, script.UnreliableEvents)
end

return Network
