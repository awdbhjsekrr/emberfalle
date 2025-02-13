--!strict

--[[
	Module used to centralize remotes.
]]

local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

type Event = "RemoteEvent"

type Function = "RemoteFunction" | "CreateReplicationFocusPart"

type UnreliableEvent = "UnreliableEvent"

type Remotes = {
	EVENTS: { Event },
	FUNCTIONS: { Function },
	UNRELIABLE_EVENTS: { UnreliableEvent },
}

local REMOTES: Remotes = {
	EVENTS = {
		"RemoteEvent",
	},
	FUNCTIONS = {
		"RemoteFunction",
		"CreateReplicationFocusPart",
	},
	UNRELIABLE_EVENTS = {
		"UnreliableEvent",
	},
}

local Network = {}

local function createInstances(
	className: string,
	instanceNameList: { string | Event | UnreliableEvent | Function },
	parent: Instance
)
	for _, instanceName in ipairs(instanceNameList) do
		local newInstance = Instance.new(className)
		newInstance.Name = instanceName
		newInstance.Parent = parent
	end
end

local function getRemoteEvent(remoteEventName: Event | UnreliableEvent): RemoteEvent?
	return script.Events:FindFirstChild(remoteEventName) or script.UnreliableEvents:FindFirstChild(remoteEventName)
end

local function getRemoteFunction(remoteFunctionName: Function): RemoteFunction?
	return script.Functions:FindFirstChild(remoteFunctionName)
end

function Network.connectEvent(remoteEventName: Event | UnreliableEvent, callback: (...any) -> any)
	local remoteEvent = getRemoteEvent(remoteEventName)
	assert(remoteEvent, `Cannot find remote event: {remoteEventName}`)
	if IS_SERVER then
		remoteEvent.OnServerEvent:Connect(callback)
	else
		remoteEvent.OnClientEvent:Connect(callback)
	end
end

function Network.bindFunction(remoteFunctionName: Function, callback: (...any) -> any)
	local remoteFunction = getRemoteFunction(remoteFunctionName)
	assert(remoteFunction, `Cannot find remote function: {remoteFunctionName}`)
	if IS_SERVER then
		remoteFunction.OnServerInvoke = callback
	else
		remoteFunction.OnClientInvoke = callback
	end
end

function Network.fireAllClients(remoteName: Event | UnreliableEvent, ...: any)
	assert(IS_SERVER, "Network.fireAllClients can only be called from server")
	local remoteEvent = script.Events:FindFirstChild(remoteName) :: RemoteEvent
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireAllClients(...)
end

function Network.fireClient(remoteName: Event | UnreliableEvent, player: Player, ...: any)
	assert(IS_SERVER, "Network.fireAllClients can only be called from server")
	local remoteEvent = getRemoteEvent(remoteName)
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireClient(player, ...)
end

function Network.fireServer(remoteName: Event | UnreliableEvent, ...: any)
	assert(IS_CLIENT, "Network.fireServer can only be called from client")
	local remoteEvent = getRemoteEvent(remoteName)
	assert(remoteEvent, `Could not find remote event: {remoteName}`)
	remoteEvent:FireServer(...)
end

function Network.invokeClient(remoteName: Function, player: Player, ...: any)
	assert(IS_SERVER, "Network.invokeClient can only be called from server")
	local remoteFunction = getRemoteFunction(remoteName)
	assert(remoteFunction, `Could not find remote function: {remoteName}`)
	return remoteFunction:InvokeClient(player, ...)
end

function Network.invokeServer(remoteName: Function, ...: any)
	assert(IS_CLIENT, "Network.invokeServer can only be called from client")
	local remoteFunction = getRemoteFunction(remoteName)
	assert(remoteFunction, `Could not find remote function: {remoteName}`)
	return remoteFunction:InvokeServer(...)
end

function Network.startServer()
	assert(IS_SERVER, "Network.startServer can only be called from server")
	Network._serverStarted = true
	createInstances("Folder", { "Events", "Functions", "UnreliableEvents" }, script)
	createInstances("RemoteEvent", REMOTES.EVENTS, script.Events)
	createInstances("RemoteFunction", REMOTES.FUNCTIONS, script.Functions)
	createInstances("UnreliableRemoteEvent", REMOTES.UNRELIABLE_EVENTS, script.UnreliableEvents)
end

return Network
