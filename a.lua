local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Model = script.Parent
local RegionPart = Model:WaitForChild("RegionPart")
local ZoneModule = require(ReplicatedStorage.Zone)

local LeftDoor = Model.LeftDoor.PrimaryPart
local RightDoor = Model.RightDoor.PrimaryPart
local GeneralTweenInfo = TweenInfo.new(0.7, Enum.EasingStyle.Linear, Enum.EasingDirection.In, 0, false, 0.1)

local DoorsOpened = false

local PrimaryPartCFrames = {
	["LeftDoor"] = {
		["Opened"] = CFrame.new(-277.649963, 5.79999876, 24.2999992, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		["Closed"] = CFrame.new(-277.649963, 5.79999876, 29.8999996, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	},
	["RightDoor"] = {
		["Opened"] = CFrame.new(-277.649994, 5.79999876, 41.2500015, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		["Closed"] = CFrame.new(-277.649994, 5.79999876, 35.6500015, 1, 0, 0, 0, 1, 0, 0, 0, 1)
	}
}

local Tweens = {
	["LeftDoor"] = {
		["Opening"] = TweenService:Create(LeftDoor, GeneralTweenInfo, {CFrame = PrimaryPartCFrames["LeftDoor"]["Opened"]}),
		["Closing"] = TweenService:Create(LeftDoor, GeneralTweenInfo, {CFrame = PrimaryPartCFrames["LeftDoor"]["Closed"]})
	},
	["RightDoor"] = {
		["Opening"] = TweenService:Create(RightDoor, GeneralTweenInfo, {CFrame = PrimaryPartCFrames["RightDoor"]["Opened"]}),
		["Closing"] = TweenService:Create(RightDoor, GeneralTweenInfo, {CFrame = PrimaryPartCFrames["RightDoor"]["Closed"]})
	}
}

local Zone = ZoneModule.new(RegionPart)

Zone.playerEntered:Connect(function(Player)
	if not DoorsOpened then
		DoorsOpened = true
		
		Tweens["LeftDoor"]["Closing"]:Pause()
		Tweens["RightDoor"]["Closing"]:Pause()
		
		Tweens["LeftDoor"]["Opening"]:Play()
		Tweens["RightDoor"]["Opening"]:Play()
	end
end)

Zone.playerExited:Connect(function(Player)
	wait(0.5)
	
	Tweens["LeftDoor"]["Opening"]:Pause()
	Tweens["RightDoor"]["Opening"]:Pause()
	
	Tweens["LeftDoor"]["Closing"]:Play()
	Tweens["RightDoor"]["Closing"]:Play()
	
	DoorsOpened = false
end)
