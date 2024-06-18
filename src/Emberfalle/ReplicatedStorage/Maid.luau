--!strict

--[[
	Basic implementation of a connection manager.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Source.Packages.signal)

type Connection = RBXScriptConnection | Signal.Connection

export type ClassType = typeof(setmetatable(
	{} :: {
		_connections: {}
	}

))

local Maid = {}
Maid.__index = Maid

function Maid.new()

return Maid
