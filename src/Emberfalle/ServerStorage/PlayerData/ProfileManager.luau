--!strict

--[[
	Interface for interacting with a player's ProfileStore profile.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ProfileStore = require(ServerStorage.Source.ServerPackages.profilestore)

local DEFAULT_PROFILE_DATA = require(ReplicatedStorage.Source.SharedConstants.DefaultProfileData)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

local playerStore = ProfileStore.New("PlayerStore", DEFAULT_PROFILE_DATA)
local profiles: { [Player]: typeof(playerStore:StartSessionAsync("", { Cancel = function() end })) } = {}

local ProfileManager = {}

local function onPlayerRemoving(player: Player, msg: string?)
	local profile = profiles[player]
	if profile then
		profiles[player] = nil
	end
	player:Kick(msg)
end

local function onPlayerAdded(player: Player)
	local userId = player.UserId

	local profile = playerStore:StartSessionAsync(`{userId}`, {
		Cancel = function()
			return player.Parent ~= Players
		end,
	})

	if profile ~= nil then
		profile:AddUserId(userId)
		profile:Reconcile()

		profile.OnSessionEnd:Connect(function()
			onPlayerRemoving(player)
		end)

		if player:IsDescendantOf(Players) then
			profiles[player] = profile
		else
			profile:EndSession()
		end
	else
		onPlayerRemoving(player, "Failed to load data! Try rejoining.")
	end
end

function listenForPlayers()
	safePlayerAdded(function(newPlayer: Player)
		onPlayerAdded(newPlayer)
	end)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

function waitForDataReady(player: Player)
	while true do
		if not player or not player:IsDescendantOf(Players) then
			return
		end
		local profile = profiles[player]
		if profile and profile:IsActive() then
			return
		end
		task.wait()
	end
end

function ProfileManager.get<T>(player: Player, path: { [number]: any }?): T | DEFAULT_PROFILE_DATA.ClassType?
	waitForDataReady(player)
	local profile = profiles[player]
	if not profile or not profile:IsActive() then
		return
	end
	if typeof(path) == "table" then
		local pointer: DEFAULT_PROFILE_DATA.ClassType = profile.Data
		for i = 1, #path - 1 do
			pointer = pointer[path[i]]
		end
		return pointer[path[#path]]
	else
		return profile.Data
	end
end

function ProfileManager.set(player: Player, path: { [number]: any }, value: any)
	waitForDataReady(player)
	local profile = profiles[player]
	if not profile or not profile:IsActive() then
		return
	end
	if typeof(path) == "table" then
		local pointer: DEFAULT_PROFILE_DATA.ClassType = profile.Data
		for i = 1, #path - 1 do
			pointer = pointer[path[i]]
		end
		pointer[path] = value
	else
		warn(`Attempt to set {player.Name} data failed. Invalid path: {path}`)
	end
end

function ProfileManager.increment(player: Player, path: { [number]: any }, value: number)
	local profile = profiles[player]
	if not profile or not profile:IsActive() then
		return
	end
	local currentValue = ProfileManager.get(player, path)
	if type(currentValue) == "number" then
		ProfileManager.set(player, path, currentValue + value)
	else
		warn(`Attempt to increment {player.Name} data failed. Can only increment numbers got: {currentValue}`)
	end
end

function ProfileManager.start()
	listenForPlayers()
end

return ProfileManager
