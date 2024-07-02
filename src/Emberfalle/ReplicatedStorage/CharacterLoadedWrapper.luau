--!strict

local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Source.Packages.signal)
local ConnectionMaid = require(ReplicatedStorage.Source.ConnectionMaid)
local waitForChildOfClass = require(ReplicatedStorage.Source.Utility.waitForChildOfClass)

local CharacterLoadedWrapper = {}
CharacterLoadedWrapper.__index = CharacterLoadedWrapper

export type ClassType = typeof(setmetatable(
	{} :: {
		loaded: Signal.Signal<nil>,
		died: Signal.Signal<nil>,
		_player: Player,
		_destroyed: boolean,
		_connections: ConnectionMaid.ClassType,
	},
	CharacterLoadedWrapper
))

local function isPrimaryPartSet(character: Model)
	return if character.PrimaryPart then true else false
end

local function isHumanoidRootPartSet(humanoid: Humanoid)
	return if humanoid.RootPart then true else false
end

local function isHumanoidAlive(character: Model)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return false
	end
	return isHumanoidRootPartSet(humanoid) and humanoid.Health > 0
end

function CharacterLoadedWrapper.new(player: Player)
	local self = {
		loaded = Signal.new(),
		died = Signal.new(),
		_player = player,
		_destroyed = false,
		_connections = ConnectionMaid.new(),
	}
	setmetatable(self, CharacterLoadedWrapper)
	self._listenForCharacterAdded(self)
	return self
end

function CharacterLoadedWrapper.getCharacter(self: ClassType)
	if not self._player.Character then
		self._player.CharacterAdded:Wait()
	end
	return self._player.Character :: Model
end

function CharacterLoadedWrapper.isLoaded(self: ClassType)
	local character = self:getCharacter()
	return isPrimaryPartSet(character) and isHumanoidAlive(character) and character:IsDescendantOf(Workspace)
end

function CharacterLoadedWrapper._waitForLoaded(self: ClassType)
	local character = self:getCharacter()
	if not self:isLoaded() then
		if not character:IsDescendantOf(Workspace) then
			character.AncestryChanged:Wait()
		end
		if character.Parent then
			if not isPrimaryPartSet(character) then
				character:GetPropertyChangedSignal("PrimaryPart"):Wait()
			end
			local humanoid = waitForChildOfClass(character, "Humanoid") :: Humanoid
			while not isHumanoidRootPartSet(humanoid) do
				humanoid.Changed:Wait()
			end
		end
		if not self:isLoaded() then
			return
		end
	end
	if self._destroyed then
		return
	end
	self:_listenForDeath()
	self.loaded:Fire()
end

function CharacterLoadedWrapper._listenForCharacterAdded(self: ClassType)
	task.spawn(function()
		local character = self._player.Character
		if character then
			if self:isLoaded() then
				self:_listenForDeath()
			else
				self:_waitForLoaded()
			end
		end
		local characterAddedConnection = self._player.CharacterAdded:Connect(function()
			self:_waitForLoaded()
		end)
		self._connections:add(characterAddedConnection)
	end)
end

function CharacterLoadedWrapper._listenForDeath(self: ClassType)
	local character = self:getCharacter()
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
		self.died:Fire()
	end

	diedConnection = humanoid.Died:Connect(onDied)

	removedConnection = character.AncestryChanged:Connect(function()
		if not character:IsDescendantOf(Workspace) then
			onDied()
		end
	end)

	self._connections:add(diedConnection, removedConnection)
end

function CharacterLoadedWrapper.destroy(self: ClassType)
	self.loaded:DisconnectAll()
	self.died:DisconnectAll()
	self._destroyed = true
	self._connections:disconnect()
end

return CharacterLoadedWrapper
