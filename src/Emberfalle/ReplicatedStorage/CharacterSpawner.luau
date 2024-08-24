--!strict

--[[
	Handles respawning of the player character on death and CharacterAdded and Died events.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local characterContainer

local CharacterSpawner = {}
CharacterSpawner._respawnLoopActive = {} :: { [Player]: boolean }
CharacterSpawner._diedConnectionByPlayer = {} :: { [Player]: RBXScriptConnection }
CharacterSpawner._characterAddedConnectionByPlayer = {} :: { [Player]: RBXScriptConnection }
CharacterSpawner._characterAddedCallbacksByPlayer = {} :: { [Player]: { [string]: (character: Model) -> nil } }

function CharacterSpawner._characterAdded(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	if not characterContainer then
		characterContainer = Instance.new("Folder")
		characterContainer.Name = "Characters"
		characterContainer.Parent = Workspace
	end
	if CharacterSpawner._characterAddedCallbacksByPlayer[player] then
		for _, callback in pairs(CharacterSpawner._characterAddedCallbacksByPlayer[player]) do
			task.spawn(callback, character)
		end
	end
	local diedConnection
	diedConnection = humanoid.Died:Connect(function()
		if player and player:IsDescendantOf(Players) then
			diedConnection:Disconnect()
			CharacterSpawner._diedConnectionByPlayer[player] = nil
			if RunService:IsServer() then
				task.wait(Players.RespawnTime)
				player:LoadCharacter()
			end
		end
	end)
	CharacterSpawner._diedConnectionByPlayer[player] = diedConnection
	character.Parent = characterContainer
end

function CharacterSpawner.addCharacterAddedCallback(
	player: Player,
	callbackId: string,
	callback: (character: Model) -> nil
)
	if not CharacterSpawner._characterAddedCallbacksByPlayer[player] then
		CharacterSpawner._characterAddedCallbacksByPlayer[player] = {}
	end
	assert(
		not CharacterSpawner._characterAddedCallbacksByPlayer[player][callbackId],
		`callbackId {callbackId} already in use for player: {player}`
	)
	CharacterSpawner._characterAddedCallbacksByPlayer[player][callbackId] = callback
	if not CharacterSpawner._respawnLoopActive[player] then
		local characterAddedConnection = player.CharacterAdded:Connect(CharacterSpawner._characterAdded)
		CharacterSpawner._characterAddedConnectionByPlayer[player] = characterAddedConnection
	end
	if player.Character then
		callback(player.Character)
	end
end

function CharacterSpawner._disconnectConnections(player: Player)
	local diedConnection = CharacterSpawner._diedConnectionByPlayer[player]
	local characterAddedConnection = CharacterSpawner._characterAddedConnectionByPlayer[player]
	if diedConnection then
		diedConnection:Disconnect()
		CharacterSpawner._diedConnectionByPlayer[player] = nil
	end
	if characterAddedConnection then
		characterAddedConnection:Disconnect()
		CharacterSpawner._characterAddedConnectionByPlayer[player] = nil
	end
end

function CharacterSpawner.removeCharacterAddedCallback(player: Player, callbackId: string)
	assert(CharacterSpawner._characterAddedCallbacksByPlayer[player], `{player} has no callbacks to remove`)
	CharacterSpawner._characterAddedCallbacksByPlayer[player][callbackId] = nil
	local callbackCount = 0
	for _, _ in pairs(CharacterSpawner._characterAddedCallbacksByPlayer[player]) do
		callbackCount += 1
	end
	if callbackCount <= 0 then
		CharacterSpawner._characterAddedCallbacksByPlayer[player] = nil
		if not CharacterSpawner._respawnLoopActive[player] then
			CharacterSpawner._disconnectConnections(player)
		end
	end
end

function CharacterSpawner.clearCharacterAddedCallbacks(player: Player)
	assert(CharacterSpawner._characterAddedCallbacksByPlayer[player], `{player} has no callbacks to clear`)
	CharacterSpawner._characterAddedCallbacksByPlayer[player] = nil
	if not CharacterSpawner._respawnLoopActive[player] then
		CharacterSpawner._disconnectConnections(player)
	end
end

function CharacterSpawner.startRespawnLoop(player: Player)
	assert(IS_SERVER, "CharacterSpawner.startRespawnLoop can only be called from server")
	CharacterSpawner._respawnLoopActive[player] = true
	if not CharacterSpawner._characterAddedConnectionByPlayer[player] then
		if player.Character then
			CharacterSpawner._characterAdded(player.Character)
		end
		player.CharacterAdded:Connect(CharacterSpawner._characterAdded)
	end
	if not player.Character then
		player:LoadCharacter()
	end
end

function CharacterSpawner.stopRespawnLoop(player: Player)
	assert(IS_SERVER, "CharacterSpawner.stoptRespawnLoop can only be called from server")
	CharacterSpawner._respawnLoopActive[player] = true
	CharacterSpawner.clearCharacterAddedCallbacks(player)
	CharacterSpawner._disconnectConnections(player)
end

return CharacterSpawner
