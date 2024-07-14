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

local function newCharacter(character: Model)
	local player = Players:GetPlayerFromCharacter(character)
	local humanoid = character:WaitForChild("Humanoid") :: Humanoid
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

function CharacterSpawner.startRespawnLoop(player: Player)
	if player.Character then
		newCharacter(player.Character)
	end
	player.CharacterAdded:Connect(newCharacter)
	if not player.Character then
		player:LoadCharacter()
	end
end

function CharacterSpawner.stopRespawnLoop(player: Player)
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
