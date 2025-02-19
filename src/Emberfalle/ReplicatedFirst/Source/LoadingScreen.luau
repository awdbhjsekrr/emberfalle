--!strict

--[[
	Controls the initial loading screen on player join.
]]

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local MIN_RUN_TIME = 10

local LoadingScreen = {}

local gui = ReplicatedFirst.Instances.LoadingGui
local title = gui.Frame.Title
local icon = title.ImageLabel
local versionLabel = title.Version
local loadingFrame = gui.Frame.Loading
local loadingText = loadingFrame.TextLabel
local leftBracket = loadingFrame.Bar.LeftBracket
local rightBracket = loadingFrame.Bar.RightBracket
local progressBar = loadingFrame.Bar.Container.Progress
local progressLabel = progressBar.TextLabel

local slowTweenTime = 3
local averageTweenTime = 1.25
local fastTweenTime = 0.25
local slowTweenInfo = TweenInfo.new(slowTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local fastTweenInfo = TweenInfo.new(fastTweenTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

local function setupGuiForStartupAnimation()
	loadingFrame.Size = UDim2.new(0.75, 0, 0.2, 0)
	title.TextTransparency = 1
	icon.ImageTransparency = 1
	loadingText.TextTransparency = 1
	leftBracket.TextTransparency = 1
	rightBracket.TextTransparency = 1
	progressLabel.TextTransparency = 1
	versionLabel.TextTransparency = 1
	progressBar.BackgroundTransparency = 0
	progressBar.Size = UDim2.new(0, 0, 0.75, 0)
	progressLabel.Text = "Progress: 0%"
	gui.Frame.Position = UDim2.new(0.5, 0, 0.6, 0)
end

local function fadeGuiObject(guiObject: GuiObject, startingValue: number, newValue: number, tweenInfo: TweenInfo?)
	local thisTweenInfo = tweenInfo or slowTweenInfo
	if guiObject:IsA("ImageLabel") then
		guiObject.ImageTransparency = startingValue
		TweenService:Create(guiObject, thisTweenInfo, {
			ImageTransparency = newValue,
		}):Play()
	elseif guiObject:IsA("TextLabel") then
		guiObject.TextTransparency = startingValue
		TweenService:Create(guiObject, thisTweenInfo, {
			TextTransparency = newValue,
		}):Play()
	elseif guiObject:IsA("Frame") then
		guiObject.BackgroundTransparency = startingValue
		TweenService:Create(guiObject, thisTweenInfo, {
			BackgroundTransparency = newValue,
		}):Play()
	end
end

progressBar:GetPropertyChangedSignal("Size"):Connect(function()
	progressLabel.Text = `Progress: {-math.floor(progressBar.Size.X.Scale * 100)}%`
end)

gui.Background.Container.ChildAdded:Connect(function(newParticle: ImageLabel)
	local particleSize = math.random(40, 100) * 0.0001
	local transparency = math.random(50, 90) * 0.01
	local colors = {
		Color3.fromHex("A6FF40"),
		Color3.fromHex("FFDE26"),
		Color3.fromHex("D3FFF2"),
	}
	local thisColor = colors[math.random(1, #colors)]
	newParticle.Size = UDim2.new(particleSize, 0, particleSize, 0)
	newParticle.ImageColor3 = thisColor
	newParticle.Position = UDim2.new(math.random(0, 100) * 0.01, 0, math.random(0, 100) * 0.01, 0)
	fadeGuiObject(newParticle, 1, transparency)
	TweenService:Create(newParticle, TweenInfo.new(slowTweenTime + 5), {
		Position = newParticle.Position - UDim2.new(0, 0, 0.1, 0),
	}):Play()
	task.wait(slowTweenTime)
	fadeGuiObject(newParticle, transparency, 1, TweenInfo.new(0.75))
	task.wait(0.75)

	newParticle:Destroy()
end)

local function playEndingAnimation()
	local CameraController = require(ReplicatedStorage.Source.CameraController)
	fadeGuiObject(title, 0, 1)
	fadeGuiObject(icon, 0, 1)
	fadeGuiObject(versionLabel, 0, 1)
	TweenService:Create(gui.Frame, TweenInfo.new(slowTweenTime + 0.5), {
		Position = UDim2.new(0.5, 0, 0.3, 0),
	}):Play()
	CameraController.moveTo(CameraController.locations.Loading)
	task.wait(averageTweenTime)
	fadeGuiObject(gui.Background, 0, 1)
	CameraController.tweenTo(CameraController.locations.MainMenu, 5)
	task.wait(5)
end

local function playStartupAnimation()
	setupGuiForStartupAnimation()

	task.wait(3)

	-- Move up
	TweenService:Create(gui.Frame, TweenInfo.new(slowTweenTime - 0.5), {
		Position = UDim2.new(0.5, 0, 0.5, 0),
	}):Play()

	local spawnParticles = true

	-- Particle effect
	task.spawn(function()
		while spawnParticles do
			task.wait(math.random(1, 100) * 0.01)
			local newParticle = gui.Assets.Particle:Clone()
			newParticle.Parent = gui.Background.Container
		end
	end)

	-- Fade in
	fadeGuiObject(title, 1, 0)
	fadeGuiObject(icon, 1, 0)
	fadeGuiObject(versionLabel, 1, 0)
	task.wait(slowTweenTime)
	fadeGuiObject(loadingText, 1, 0.5)
	task.wait(1)
	fadeGuiObject(leftBracket, 1, 0)
	fadeGuiObject(rightBracket, 1, 0)
	fadeGuiObject(progressLabel, 1, 0.5)

	task.wait(slowTweenTime + 0.1)

	for i = 0, 1, 0.01 do
		task.wait(math.random(1, 20) * 0.01)
		TweenService:Create(progressBar, fastTweenInfo, {
			Size = UDim2.new(-i, 0, progressBar.Size.Y.Scale, 0),
		}):Play()
	end

	task.wait(1)
	fadeGuiObject(leftBracket, 0, 1, TweenInfo.new(fastTweenTime))
	fadeGuiObject(rightBracket, 0, 1, TweenInfo.new(fastTweenTime))
	fadeGuiObject(progressLabel, 0.5, 1, TweenInfo.new(fastTweenTime))
	fadeGuiObject(progressBar, 0, 1, TweenInfo.new(fastTweenTime))
	fadeGuiObject(loadingText, 0.5, 1, TweenInfo.new(fastTweenTime))
	task.wait(fastTweenTime)
	TweenService:Create(loadingFrame, TweenInfo.new(averageTweenTime), {
		Size = UDim2.new(loadingFrame.Size.X.Scale, 0, 0, 0),
	}):Play()

	spawnParticles = false

	task.wait(slowTweenTime)
end

function LoadingScreen.enable()
	local startTime = tick()
	gui.Parent = Players.LocalPlayer.PlayerGui
	playStartupAnimation()
	local endTime = tick()
	local remainingRunTime = MIN_RUN_TIME - (endTime - startTime)
	if remainingRunTime > 0 then
		task.wait(remainingRunTime)
	end
end

function LoadingScreen.disable()
	playEndingAnimation()
	gui.Parent = ReplicatedFirst.Instances
end

return LoadingScreen
