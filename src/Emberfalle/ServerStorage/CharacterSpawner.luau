--!strict

--[[
	Handles respawning of the player character on death.
]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local CharacterContainer = Instance.new("Folder")
CharacterContainer.Name = "Characters"
CharacterContainer.Parent = Workspace

local CharacterSpawner = {}
CharacterSpawner._diedConnectionByPlayer = {} :: { [Player]: RBXScriptConnection }
CharacterSpawner._characterAddedConnectionByPlayer = {} :: { [Player]: RBXScriptConnection }
CharacterSpawner._characterAddedCallbacksByPlayer = {} :: { [Player]: { [string]: (character: Model) -> nil } }

function CharacterSpawner._characterAdded(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	if CharacterSpawner._characterAddedCallbacksByPlayer[player] then
		for _, callback in pairs(CharacterSpawner._characterAddedCallbacksByPlayer[player]) do
			callback(character)
		end
	end
	local diedConnection
	diedConnection = humanoid.Died:Connect(function()
		task.wait(Players.RespawnTime)
		if player and player:IsDescendantOf(Players) then
			diedConnection:Disconnect()
			CharacterSpawner._diedConnectionByPlayer[player] = nil
			player:LoadCharacter()
		end
	end)
	CharacterSpawner._diedConnectionByPlayer[player] = diedConnection
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
	if player.Character then
		callback(player.Character)
	end
end

function CharacterSpawner.removeCharacterAddedCallback(player: Player, callbackId: string)
	assert(CharacterSpawner._characterAddedCallbacksByPlayer[player], `{player} has no callbacks to remove`)
	CharacterSpawner._characterAddedCallbacksByPlayer[player][callbackId] = nil
end

function CharacterSpawner.clearCharacterAddedCallbacks(player: Player)
	assert(CharacterSpawner._characterAddedCallbacksByPlayer[player], `{player} has no callbacks to clear`)
	CharacterSpawner._characterAddedCallbacksByPlayer[player] = nil
end

function CharacterSpawner.startRespawnLoop(player: Player)
	if player.Character then
		CharacterSpawner._characterAdded(player.Character)
	end
	player.CharacterAdded:Connect(CharacterSpawner._characterAdded)
	if not player.Character then
		player:LoadCharacter()
	end
end

function CharacterSpawner.stopRespawnLoop(player: Player)
	CharacterSpawner.clearCharacterAddedCallbacks(player)
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

return CharacterSpawner
