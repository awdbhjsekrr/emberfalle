--!strict

--[[
	Manages player anc NPC collisions.
]]

local PhysicsService = game:GetService("PhysicsService")
local Workspace = game:GetService("Workspace")

type CollisionGroup = "PlayerCharacters" | "NonPlayerCharacters"

local COLLISION_GROUPS: { CollisionGroup } = {
	"PlayerCharacters" :: "PlayerCharacters",
	"NonPlayerCharacters" :: "NonPlayerCharacters",
}

local DEFAULT_GROUP_COLLIDABLES: { [CollisionGroup]: { [CollisionGroup]: boolean } } = {
	["PlayerCharacters"] = {
		["PlayerCharacters"] = false,
		["NonPlayerCharacters"] = false,
	},
}

local DEFAULT_INSTANCE_GROUPS: { [Instance]: CollisionGroup } = {
	[Workspace.Npcs] = "NonPlayerCharacters",
}

local Collisions = {}

function Collisions.setCollisionGroupsCollidable(
	collisionGroup1: CollisionGroup,
	collisionGroup2: CollisionGroup,
	collidable: boolean
)
	PhysicsService:CollisionGroupSetCollidable(collisionGroup1, collisionGroup2, collidable)
end

function Collisions._setCollisionGroupRecursive(instance: Instance, collisionGroup: CollisionGroup)
	for _, obj in ipairs(instance:GetChildren()) do
		if obj:IsA("BasePart") then
			obj.CollisionGroup = collisionGroup
		end
		Collisions._setCollisionGroupRecursive(obj, collisionGroup)
	end
end

function Collisions.setCollisionGroup(instance: Instance, collisionGroup: CollisionGroup)
	if instance:IsA("BasePart") then
		instance.CollisionGroup = collisionGroup
	else
		Collisions._setCollisionGroupRecursive(instance, collisionGroup)
	end
end

function Collisions.start()
	for _, collisionGroup in ipairs(COLLISION_GROUPS) do
		PhysicsService:RegisterCollisionGroup(collisionGroup)
	end
	for collisionGroup1, collidableList in pairs(DEFAULT_GROUP_COLLIDABLES) do
		for collisionGroup2, collidable in pairs(collidableList) do
			Collisions.setCollisionGroupsCollidable(
				collisionGroup1 :: CollisionGroup,
				collisionGroup2 :: CollisionGroup,
				collidable
			)
		end
	end
	for instance, collisionGroup in pairs(DEFAULT_INSTANCE_GROUPS) do
		Collisions.setCollisionGroup(instance, collisionGroup :: CollisionGroup)
	end
end

return Collisions
