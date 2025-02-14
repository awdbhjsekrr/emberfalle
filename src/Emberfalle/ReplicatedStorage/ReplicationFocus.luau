--!strict

--[[
	Workaround to changing ReplicationFocus to the player's
	camera.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CollectionService = game:GetService("CollectionService")

local Network = ReplicatedStorage.Network

local IS_SERVER = RunService:IsServer()
local IS_CLIENT = RunService:IsClient()

local ReplicationFocus = {}

local ReplicationFocusContainer: Model
local myReplicationFocus: Part
local replicationFocusCache: { [Player]: Part } = {}

local function onPlayerRemoving(player: Player)
	local replicationFocus = replicationFocusCache[player]
	if not replicationFocus then
		return
	end
	replicationFocus:Destroy()
	replicationFocusCache[player] = nil
end

function ReplicationFocus.startServer()
	assert(IS_SERVER, "startServer can only be called by the server.")
	ReplicationFocusContainer = Instance.new("Model")
	ReplicationFocusContainer.Name = "ReplicationFocusContainer"
	ReplicationFocusContainer.Parent = workspace
	ReplicationFocusContainer.ModelStreamingMode = Enum.ModelStreamingMode.Persistent
	Network.CreateReplicationFocusPart.OnServerInvoke = function(player: Player)
		print("Creating ReplicationFocus part")
		if replicationFocusCache[player] then
			warn(`ReplicationFocus part already exists for {player}`)
			return
		end
		local newPart = Instance.new("Part")
		newPart.Anchored = false
		newPart.Parent = ReplicationFocusContainer
		newPart.Name = `{player.UserId}ReplicationFocus`
		newPart.Transparency = 1
		newPart.Size = Vector3.new(1, 1, 1)
		newPart.CanCollide = false
		newPart:SetNetworkOwner(player)
		player.ReplicationFocus = newPart
		replicationFocusCache[player] = newPart
		return true
	end
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function ReplicationFocus.startClient()
	assert(IS_CLIENT, "startClient can only be called by the client.")
	if myReplicationFocus then
		warn("ReplicationFocus already created.")
		return
	end
	local createPartSuccess = Network.CreateReplicationFocusPart:InvokeServer()
	assert(createPartSuccess ~= nil, "Error creating new ReplicationFocus.")
	local player = Players.LocalPlayer
	local camera = workspace.CurrentCamera
	local myTag = `{player.UserId}ReplicationFocus`
	local newReplicationFocus: RBXScriptConnection
	newReplicationFocus = CollectionService:GetInstanceAddedSignal(myTag):Connect(function()
		local tagged: { Part } = CollectionService:GetTagged(myTag)
		if not tagged or #tagged <= 0 then
			return
		end
		newReplicationFocus:Disconnect()
		myReplicationFocus = tagged[1]
		RunService.Heartbeat:Connect(function()
			if myReplicationFocus then
				myReplicationFocus.CFrame = camera.CFrame
			end
		end)
	end)
end

return ReplicationFocus
