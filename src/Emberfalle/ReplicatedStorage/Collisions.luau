--!strict

--[[
	Manages player anc NPC collisions.
]]

local PhysicsService = game:GetService("PhysicsService")

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

function Collisions.setCollisionGroup(instance: Model | Folder | BasePart, collisionGroup: CollisionGroup)
	if instance:IsA("Model") or instance:IsA("Folder") then
		Collisions._setCollisionGroupRecursive(instance, collisionGroup)
	else
		instance.CollisionGroup = collisionGroup
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
end

return Collisions
