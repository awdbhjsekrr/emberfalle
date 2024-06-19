--!strict
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Source.Packages.signal)
local Maid = require(ReplicatedStorage.Source.Maid)

local CharacterLoadedWrapper = {}
CharacterLoadedWrapper.__index = CharacterLoadedWrapper

export type ClassType = typeof(setmetatable(
	{} :: {
		loaded: Signal.Signal<nil>,
		died: Signal.Signal<nil>,
		_player: Player,
		_destroyed: boolean,
		_connections: Maid.ClassType,
	},
	CharacterLoadedWrapper
))

function CharacterLoadedWrapper.new(player: Player)
	local self = {
		loaded = Signal.new(),
		died = Signal.new(),
		_player = player,
		_destroyed = false,
		_maid = Maid.new(),
	}
	setmetatable(self, CharacterLoadedWrapper)
	return self
end

function CharacterLoadedWrapper._listenForDeath(self: ClassType, character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid") :: Humanoid

	local alreadyDead = false
	local diedConnection, removedConnection

	local function onDied()
		if alreadyDead then
			return
		end
		alreadyDead = true
		diedConnection:Disconnect()
		removedConnection:Disconnect()
		self.died:Fire(character)
	end

	diedConnection = humanoid.Died:Connect(onDied)

	removedConnection = character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(Workspace) then
			onDied()
		end
	end)

	self._connections:add(diedConnection, removedConnection)
end

return CharacterLoadedWrapper
