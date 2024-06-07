local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ServerPackages = ServerScriptService:WaitForChild("ServerPackages")
local Common = ReplicatedStorage:WaitForChild("Common")

local ProfileService = require(ServerPackages.profileservice)
local ReplicaService = require(ServerPackages.replicaservice)
local Log = require(Common.Core.Log)

local config = {
	profileTemplate = {
		joinCount = 0,
	},
	datastore = "aaaaaaaaaaaaaaaaaaaaaaaaaaaab",
}

local playerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")
local profileStore = ProfileService.GetProfileStore(config.datastore, config.profileTemplate)

local profileCache = {}
local replicaCache = {}

local UserData = {}

local function playerAdded(player: Player)
	local userId = player.UserId
	local profile = profileStore:LoadProfileAsync(`Player_{userId}`)
	if profile ~= nil then
		profile:AddUserId(userId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			Log.debug(`Releasing profile for player: {player}`)
			replicaCache[userId]:Destroy()
			profileCache[userId] = nil
			player:Kick()
			return
		end)
		if player:IsDescendantOf(Players) == true then
			profileCache[userId] = profile
			replicaCache[userId] = ReplicaService.NewReplica({
				ClassToken = playerProfileClassToken,
				Data = profile.Data,
				Replication = "All",
				Tags = { Player = player },
				Parent = nil,
				WriteLib = nil,
			} :: any) :: any
		else
			profile:Release()
		end
	else
		player:Kick("Failed to load data! Try rejoining.")
		Log.warn(`Failed to load data for player: {player}`)
	end
end

local function playerRemoving(player: Player)
	local userId = player.UserId
	local cachedProfile = profileCache[userId]
	if cachedProfile then
		cachedProfile:Release()
	end
end

local function waitForDataReady(player: Player)
	local userId = player.UserId
	while true do
		if not player then
			return
		end
		if profileCache[userId] ~= nil and replicaCache[userId] ~= nil then
			return
		end
		task.wait()
	end
end

local function get(player: Player, path: { [number]: any }?): unknown
	waitForDataReady(player)
	local userId = player.UserId
	local profile = profileCache[userId]
	local replica = replicaCache[userId]
	if profile ~= nil and replica ~= nil and replica:IsActive() == true then
		if path ~= nil then
			local pointer = profile.Data
			for i = 1, #path - 1 do
				pointer = pointer[path[i]]
			end
			return pointer[path[#path]]
		else
			return profile.Data
		end
	end
	return
end

local function set(player: Player, path: { [number]: any }, value: any)
	waitForDataReady(player)
	local userId = player.UserId
	local profile = profileCache[userId]
	local replica = replicaCache[userId]
	if profile ~= nil and replica ~= nil and replica:IsActive() == true then
		local pointer = profile.Data
		for i = 1, #path - 1 do
			pointer = pointer[path[i]]
		end
		pointer[path[#path]] = value
		replica:SetValue(path, value)
	end
end

local function increment(player: Player, path: { [number]: any }, value: number)
	local currentValue = get(player, path)
	if typeof(currentValue) == "number" then
		set(player, path, currentValue + value)
	else
		Log.warn(`Increment can only be used on numbers: {player}, {path}`)
	end
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		task.spawn(playerRemoving, player)
	end
end)

Players.PlayerAdded:Connect(playerAdded)
Players.PlayerRemoving:Connect(playerRemoving)

UserData.get = get
UserData.set = set
UserData.increment = increment

return UserData
