--!strict

--[[
	Interface for interacting with a player's ProfileStore profile.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local ProfileStore = require(ServerStorage.Source.ServerPackages.profilestore)

local safePlayerAdded = require(ReplicatedStorage.Source.Utility.safePlayerAdded)

local DEFAULT_PROFILE_DATA = require(ReplicatedStorage.Source.SharedConstants.DefaultProfileData)

local Network = ReplicatedStorage.Network

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
			Network.ProfileUpdated:FireAllClients(player, profile.Data)
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
		warn("Error getting profile.")
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
		warn("Error getting profile.")
		return
	end
	if typeof(path) == "table" then
		local pointer: DEFAULT_PROFILE_DATA.ClassType = profile.Data
		for i = 1, #path - 1 do
			pointer = pointer[path[i]]
		end
		pointer[path] = value
		Network.ProfileUpdated:FireAllClients(player, profile.Data)
	else
		warn(`Attempt to set data failed. Invalid path.`)
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
		warn(`Attempt to increment data failed. Can only increment numbers.`)
	end
end

function ProfileManager.start()
	listenForPlayers()
	Network.FetchProfiles.OnServerInvoke = function()
		local resp = {}
		for player, profile in pairs(profiles) do
			if profile and profile:IsActive() then
				resp[player] = profile.Data
			end
		end
		return resp
	end
end

return ProfileManager
