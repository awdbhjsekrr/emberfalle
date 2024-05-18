local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local ServerPackages = ServerScriptService:WaitForChild("serverpackages")

local ProfileService = require(ServerPackages.profileservice)
local ReplicaService = require(ServerPackages.replicaservice)

local config = {
	profileTemplate = {},
	datastore = "aaaaaaaaaaaaaaaaaaaaaaaaaaaab",
}

local playerProfileClassToken = ReplicaService.NewClassToken("PlayerProfile")
local profileStore = ProfileService.GetProfileStore(config.datastore, config.profileTemplate)
local profileCache = {}

local function playerAdded(player: Player)
	local userId = player.UserId
	local profile = profileStore:LoadProfileAsync(`Player_{userId}`)
	if profile ~= nil then
		profile:AddUserId(userId)
		profile:Reconcile()
		profile:ListenToRelease(function()
			profileCache[player].Replica:Destroy()
			profileCache[player] = nil
			player:Kick()
			return
		end)
		if player:IsDescendantOf(Players) == true then
			local playerProfile = {
				Profile = profile,
				Replica = ReplicaService.NewReplica({
					ClassToken = playerProfileClassToken,
					Data = profile.Data,
					Replication = "All",
					Tags = { Player = player },
					Parent = nil,
					WriteLib = nil,
				} :: any) :: any,
				_player = player,
			}
			profileCache[player] = playerProfile
		else
			profile:Release()
		end
	else
		player:Kick("Failed to load data! Try rejoining.")
		error(`Failed to load data: {player}`)
	end
end

local function playerRemoving(player: Player)
	local cachedProfile = profileCache[player]
	if cachedProfile then
		local profile = cachedProfile.Profile
		if profile then
			profile:Release()
			player:Kick()
		end
	end
end

local function waitForDataReady(player: Player)
	while true do
		if player:IsDescendantOf(Players) == false or profileCache[player] ~= nil then
			return true
		end
		task.wait()
	end
end

local function get(player: Player, path: { [number]: any }?): unknown
	waitForDataReady(player)
	local profile = profileCache[player]
	if profile ~= nil and profile.Replica:IsActive() == true then
		if path ~= nil then
			local dir = profile.Replica.Data
			for i, v in ipairs(path) do
				if dir[v] ~= nil then
					if #path == i then
						return dir[v]
					else
						if typeof(dir[v]) == "table" then
							dir = dir[v]
						else
							error(`Failed userdata get! Invalid path: {player}, {profile.Replica.Data}, {path}`)
						end
					end
				end
			end
		else
			return profile.Replica.Data
		end
	end
	return
end

local function set(player: Player, path: { [number]: any }, value: any)
	waitForDataReady(player)
	local profile = profileCache[player]
	if profile ~= nil and profile.Replica:IsActive() == true then
		profile.Replica:SetValue(path, value)
	end
end

local function increment(player: Player, path: { [number]: any }, value: number)
	local currentValue = get(player, path)
	if typeof(currentValue) == "number" then
		set(player, path, currentValue + value)
	else
		error(`Increment can only be used on numbers: {player}, {path}`)
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

return {
	get = get,
	set = set,
	increment = increment,
}
