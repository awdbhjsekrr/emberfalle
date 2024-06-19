--!strict

--[[
	Interface for interacting with a player's ProfileService profile.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ProfileService = require(ServerStorage.Source.ServerPackages.profileservice)
local ReplicaService = require(ServerStorage.Source.ServerPackages.replicaservice)

local REQUEST_TIMEOUT = 10
local DATA_STORE_NAME = "aaaaaaaaaaaaab"
local DEFAULT_PROFILE_DATA = require(ServerStorage.Source.PlayerData.DefaultProfileData)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

local playerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")
local profileStore = ProfileService.GetProfileStore(DATA_STORE_NAME, DEFAULT_PROFILE_DATA)

local ProfileManager = {}
ProfileManager._profileCache = {}
ProfileManager._replicaCache = {}

function ProfileManager.start()
	ProfileManager._listenForPlayers()
end

function ProfileManager._onPlayerAddedAsync(player: Player)
	local userId = player.UserId
	local profile = profileStore:LoadProfileAsync(`Player_{userId}`)
	if profile ~= nil then
		profile:AddUserId(userId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			ProfileManager._replicaCache[userId]:Destroy()
			ProfileManager._profileCache[userId] = nil
			player:Kick()
			return
		end)
		if player:IsDescendantOf(Players) == true then
			ProfileManager._profileCache[userId] = profile
			ProfileManager._replicaCache[userId] = ReplicaService.NewReplica({
				ClassToken = playerProfileClassToken,
				Data = profile.Data,
				Replication = "All",
				Tags = { Player = player },
				WriteLib = nil,
			} :: any) :: any
		else
			profile:Release()
		end
	else
		player:Kick("Failed to load data! Try rejoining.")
	end
end
function ProfileManager._onplayerRemovingAsync(player: Player)
	local userId = player.UserId
	local cachedProfile = ProfileManager._profileCache[userId]
	if cachedProfile then
		cachedProfile:Release()
	end
end

function ProfileManager._listenForPlayers()
	safePlayerAdded(function(newPlayer: Player)
		ProfileManager._onPlayerAddedAsync(newPlayer)
	end)
	Players.PlayerRemoving:Connect(ProfileManager._onplayerRemovingAsync)
end

function ProfileManager._isDataReady(player: Player): boolean
	local userId = player.UserId
	local profile = ProfileManager._profileCache[userId]
	local replica = ProfileManager._replicaCache[userId]
	if profile and replica and replica:IsActive() then
		return true
	end
	return false
end

function ProfileManager._waitForDataReady(player: Player)
	local startedTick = tick()
	while true do
		if not player or (tick() - startedTick) > REQUEST_TIMEOUT then
			warn("Player doesn't exist or timed out waiting for data ready")
			return
		end
		if ProfileManager._isDataReady(player) then
			return
		end
		task.wait()
	end
end

function ProfileManager.get<T>(player: Player, path: { [number]: any }?): T | DEFAULT_PROFILE_DATA.ClassType
	ProfileManager._waitForDataReady(player)
	assert(ProfileManager._isDataReady(player), `Error loading data for player: {player}`)
	local userId = player.UserId
	local profile = ProfileManager._profileCache[userId]
	if typeof(path) == "table" then
		local pointer = profile.Data
		for i = 1, #path - 1 do
			pointer = pointer[path[i]]
		end
		return pointer[path[#path]]
	else
		return profile.Data
	end
end

function ProfileManager.set(player: Player, path: { [number]: any }, value: any)
	ProfileManager._waitForDataReady(player)
	if not ProfileManager._isDataReady(player) then
		return
	end
	local userId = player.UserId
	local profile = ProfileManager._profileCache[userId]
	local replica = ProfileManager._replicaCache[userId]
	local pointer = profile.Data
	for i = 1, #path - 1 do
		pointer = pointer[path[i]]
	end
	pointer[path[#path]] = value
	replica:SetValue(path, value)
end

function ProfileManager.increment(player: Player, path: { [number]: any }, value: number)
	local currentValue = ProfileManager.get(player, path)
	assert(typeof(currentValue) == "number", `Increment can only be used on number: {player}, {path}`)
	ProfileManager.set(player, path, currentValue + value)
end

return ProfileManager
