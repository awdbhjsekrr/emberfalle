--!strict

--[[
	Handles respawning of the player character on death and CharacterAdded and Died events.
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local IS_SERVER = RunService:IsServer()

local respawnLoopActive: { [Player]: boolean } = {}
local diedConnection: { [Player]: RBXScriptConnection } = {}
local characterAddedConnection: { [Player]: RBXScriptConnection } = {}

local characterContainer = workspace:FindFirstChild("Characters")
if not characterContainer then
	characterContainer = Instance.new("Folder")
	characterContainer.Name = "Characters"
	characterContainer.Parent = workspace
end

local CharacterSpawner = {}

local function onCharacterAdded(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
	if not characterContainer then
	end
	local newDiedConnection
	newDiedConnection = humanoid.Died:Connect(function()
		if player and player:IsDescendantOf(Players) then
			newDiedConnection:Disconnect()
			diedConnection[player] = nil
			if RunService:IsServer() then
				task.wait(Players.RespawnTime)
				player:LoadCharacter()
			end
		end
	end)
	diedConnection[player] = newDiedConnection
	character.Parent = characterContainer
end

function disconnectConnections(player: Player)
	local connection = diedConnection[player]
	if connection then
		connection:Disconnect()
		diedConnection[player] = nil
	end
end

function CharacterSpawner.startRespawnLoop(player: Player)
	assert(IS_SERVER, "CharacterSpawner.startRespawnLoop can only be called from server")
	if respawnLoopActive[player] then
		warn("Respawn loop already active.")
		return
	end
	respawnLoopActive[player] = true
	if not characterAddedConnection[player] then
		if player.Character then
			onCharacterAdded(player.Character)
		end
		player.CharacterAdded:Connect(onCharacterAdded)
	end
	if not player.Character then
		player:LoadCharacter()
	end
end

function CharacterSpawner.stopRespawnLoop(player: Player)
	assert(IS_SERVER, "CharacterSpawner.stoptRespawnLoop can only be called from server")
	if not respawnLoopActive[player] then
		warn("Respawn loop already inactive.")
		return
	end
	respawnLoopActive[player] = false
	disconnectConnections(player)
end

return CharacterSpawner
