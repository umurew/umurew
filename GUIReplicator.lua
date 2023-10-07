local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local CellColorChangeDuration = 1.5
local CellColors = {
	["Succeed"] = Color3.fromRGB(0, 255, 0),
	["Fail"] = Color3.fromRGB(255, 0, 0),
	["NoStock"] = Color3.fromRGB(255, 155, 30),
	["Default"] = Color3.fromRGB(0, 0, 0)
}

local ValidateTool = ReplicatedStorage:WaitForChild("ValidateTool")

local PartTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false)
local ColorTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false)

local TemplateGUI = script.TemplateShopGUI
local TemplateCell = script.TemplateCell
local Items = script.Items

local function GenerateGUI ()
	local CloneGUI = TemplateGUI:Clone()
	CloneGUI.Name = "ShopGUI"
	
	local ItemsFrame = CloneGUI.MainFrame.ItemsFrame
	
	local Player = Players.LocalPlayer
	local Character = Player.Character
	
	for Index, Item in pairs(Items:GetChildren()) do
		local CloneCell = TemplateCell:Clone()
		CloneCell.Name = Item.Name
		CloneCell.TextLabel.Text = "[" .. Item.Name .. "]"
		CloneCell.Parent = ItemsFrame
		
		local ViewportFrame = CloneCell.ViewportFrame
		
		local ViewportCamera = Instance.new("Camera", ViewportFrame)
		ViewportCamera.CameraType = Enum.CameraType.Scriptable
		
		ViewportFrame.CurrentCamera = ViewportCamera
		
		local CloneItem : Model = Item:Clone()
		CloneItem.Name = "ViewportItem_" .. CloneItem.Name
		CloneItem.Parent = ViewportCamera
		
		ViewportCamera.CameraSubject = CloneItem
		ViewportCamera.CFrame = CFrame.new(Vector3.new(0, 0.3, 1.2)) * CFrame.fromEulerAnglesXYZ(math.rad(0), 0, 0)
		
		local ItemProperties = CloneItem:WaitForChild("Properties")
		local ViewportCFrame = ItemProperties:FindFirstChild("ViewportCFrame")
		local ViewportSize = ItemProperties:FindFirstChild("ViewportSize")
		local ViewportSpin = ItemProperties:FindFirstChild("ViewportSpin")
		local ViewportAxis = ItemProperties:FindFirstChild("ViewportAxis")
		local ItemCost = ItemProperties:FindFirstChild("ItemCost")
		local ItemDescription = ItemProperties:FindFirstChild("ItemDescription")
		
		CloneItem.CFrame = ViewportCFrame.Value
		CloneItem.Size = ViewportSize.Value
		
		RunService.Heartbeat:Connect(function(DeltaTime)
			if ViewportAxis.Value == "X" then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(ViewportSpin.Value), 0, 0)
			elseif ViewportAxis.Value == "Y" then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(ViewportSpin.Value), 0)
			elseif ViewportAxis.Value == "Z" then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(ViewportSpin.Value))
			end
		end)
		
		CloneCell.MouseEnter:Connect(function()
			local Tween1PropertyTable = {Position = Vector3.new(CloneItem.Position.X, CloneItem.Position.Y + 0.15, CloneItem.Position.Z)}
			local Tween2PropertyTable = {Position = ViewportCFrame.Value.Position}

			local Tween1 = TweenService:Create(CloneItem, PartTweenInfo, Tween1PropertyTable)
			local Tween2 = TweenService:Create(CloneItem, PartTweenInfo, Tween2PropertyTable)

			Tween2:Pause()
			Tween1:Play()

			CloneCell.MouseLeave:Connect(function()
				Tween1:Pause()
				Tween2:Play()
			end)
		end)
		
		local CellTweens = {
			["ToSucceed"] = TweenService:Create(CloneCell.UIStroke, ColorTweenInfo, {Color = CellColors.Succeed}),
			["ToFail"] = TweenService:Create(CloneCell.UIStroke, ColorTweenInfo, {Color = CellColors.Fail}),
			["ToNoStock"] = TweenService:Create(CloneCell.UIStroke, ColorTweenInfo, {Color = CellColors.NoStock}),
			["ToDefault"] = TweenService:Create(CloneCell.UIStroke, ColorTweenInfo, {Color = CellColors.Default})
		}
		
		CloneCell.UIStroke:GetPropertyChangedSignal("Color"):Connect(function()
			for Index2, Tween in pairs(CellTweens) do
				if Tween.PlaybackState == Enum.PlaybackState.Playing then
					Tween.Completed:Wait()
				end
			end
			task.wait(CellColorChangeDuration)

			CellTweens.ToDefault:Play()
		end)
		
		CloneCell.InputBegan:Connect(function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				local ProcessHash = HttpService:GenerateGUID(true)
				
				for Index2, Tween : Tween in pairs(CellTweens) do
					if Tween.PlaybackState == Enum.PlaybackState.Playing then return end
				end

				ValidateTool:FireServer(CloneItem.Name, ItemCost.Value, ProcessHash)
				
				ValidateTool.OnClientEvent:Connect(function(Respond, HashGUID)
					--if ProcessHash ~= HashGUID then Player:Kick("Hash GUID did not match. An unexpected error.") end
					
					if Respond["Status"] == "Succeed" then
						CellTweens.ToSucceed:Play()
						print(Respond["Message"])
					elseif Respond["Status"] == "Fail" then
						CellTweens.ToFail:Play()
						warn(Respond["Message"])
					elseif Respond["Status"] == "NoStock" then
						CellTweens.ToNoStock:Play()
						warn(Respond["Message"])
					end
				end)
			end
		end)
	end
	
	CloneGUI.Parent = Player.PlayerGui
	CloneGUI.Enabled = true
end

GenerateGUI()
