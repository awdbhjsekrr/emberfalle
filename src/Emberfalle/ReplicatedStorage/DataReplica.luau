--!strict

--[[
	Gives clients access to profile information.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DEFAULT_PROFILE_DATA = require(ReplicatedStorage.Source.SharedConstants.DefaultProfileData)

local Network = ReplicatedStorage.Network

local dataCache: { [Player]: DEFAULT_PROFILE_DATA.ClassType } = {}

local DataReplica = {}

function waitForDataReady(player: Player)
	while true do
		if not player or not player:IsDescendantOf(player) then
			return
		end
		local profile = dataCache[player]
		if profile then
			return
		end
		task.wait()
	end
end

local function onPlayerRemoving(player: Player)
	dataCache[player] = nil
end

function DataReplica.get(player: Player): DEFAULT_PROFILE_DATA.ClassType
	waitForDataReady(player)
	return dataCache[player]
end

function DataReplica.startClient()
	Network.ProfileUpdated.OnClientEvent:Connect(function(player: Player, profile: DEFAULT_PROFILE_DATA.ClassType)
		dataCache[player] = profile
	end)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return DataReplica
