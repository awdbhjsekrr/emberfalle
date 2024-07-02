--!strict

--[[
	Basic implementation of a connection manager.
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Signal = require(ReplicatedStorage.Source.Packages.signal)

type Connection = RBXScriptConnection | Signal.Signal<nil>

local Maid = {}
Maid.__index = Maid

export type ClassType = typeof(setmetatable(
	{} :: {
		_connections: { Connection },
	},
	Maid
))

function Maid.new(): ClassType
	local self = {
		_connections = {},
	}
	setmetatable(self, Maid)

	return self
end

function Maid.add(self: ClassType, ...: Connection)
	for _, connection in { ... } do
		assert(not table.find(self._connections, connection), "This connection has already been added")
		table.insert(self._connections, connection)
	end
end

function Maid.remove(self: ClassType, ...: Connection)
	for _, connection in { ... } do
		local index = table.find(self._connections, connection)
		if index then
			table.remove(self._connections, index)
		end
	end
end

function Maid.disconnect(self: ClassType)
	for _, connection in self._connections do
		if typeof(connection) == "RBXScriptConnection" then
			connection:Disconnect()
		else
			connection:DisconnectAll()
		end
	end
	self._connections = {}
end

return Maid
