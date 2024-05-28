local Players = game:GetService("Players")

local UserData = require(script.userdata)

print("Server core loaded.")

local function playerAdded(player: Player)
	UserData.increment(player, { "joinCount" }, 1)
	print(UserData.get(player, { "joinCount" }))
end

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(playerAdded, player)
end

Players.PlayerAdded:Connect(playerAdded)
