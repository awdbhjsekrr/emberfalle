--!strict

--[[
	Gives clients access to profile information.
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DEFAULT_PROFILE_DATA = require(ReplicatedStorage.Source.SharedConstants.DefaultProfileData)

local Network = ReplicatedStorage.Network

local profileCache: { [Player]: DEFAULT_PROFILE_DATA.ClassType } = {}

local ProfileReplica = {}

function waitForDataReady(player: Player)
	while true do
		if not player or not player:IsDescendantOf(player) then
			return
		end
		local profile = profileCache[player]
		if profile then
			return
		end
		task.wait()
	end
end

local function onPlayerRemoving(player: Player)
	profileCache[player] = nil
end

function ProfileReplica.get(player: Player): DEFAULT_PROFILE_DATA.ClassType
	waitForDataReady(player)
	return profileCache[player]
end

function ProfileReplica.startClient()
	Network.ProfileUpdated.OnClientEvent:Connect(function(player: Player, profile: DEFAULT_PROFILE_DATA.ClassType)
		profileCache[player] = profile
	end)
	Players.PlayerRemoving:Connect(onPlayerRemoving)
end

return ProfileReplica
