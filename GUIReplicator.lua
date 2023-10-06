local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local InteractShop = ReplicatedStorage:WaitForChild("InteractShop")
local RemoveShop = ReplicatedStorage:WaitForChild("RemoveShop")
local PurchaseAmount = ReplicatedStorage:WaitForChild("PurchaseAmount")
local GiveTool = ReplicatedStorage:WaitForChild("GiveTool")

local CellColorChangeDuration = 1.5
local CellColors = {
	["Succeed"] = Color3.fromRGB(0, 255, 0),
	["Fail"] = Color3.fromRGB(255, 0, 0),
	["NoStock"] = Color3.fromRGB(255, 155, 30),
	["Default"] = Color3.fromRGB(0, 0, 0)
}

local TemplateGUI = script.TemplateShopGUI
local Items = script.Items:GetChildren()
local Tools = ReplicatedStorage:WaitForChild("Tools")

local PartTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false)
local ColorTweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Circular, Enum.EasingDirection.Out, 0, false)

local function DestroyGUI ()
	local PlayerGui = script.Parent
	if PlayerGui:FindFirstChild("ShopGUI") then PlayerGui["ShopGUI"]:Destroy() end
end

local function GenerateGUI()
	local CloneGUI = TemplateGUI:Clone()
	CloneGUI.Name = "ShopGUI"

	for i, v in pairs(Items) do
		local CloneCell = script.TemplateCell:Clone()
		CloneCell.Name = "ItemFrame_" .. v.Name
		CloneCell.TextLabel.Text = "[" .. v.Name .. "]"
		CloneCell.Parent = CloneGUI.MainFrame.ItemsFrame

		local Camera = Instance.new("Camera")
		Camera.Parent = CloneCell.ViewportFrame
		Camera.Name = "VCamera"
		Camera.CFrame = CFrame.new(Vector3.new(0, 0, 1.2)) * CFrame.fromEulerAnglesXYZ(math.rad(10), 0, 0)
		Camera.CameraType = Enum.CameraType.Scriptable

		CloneCell.ViewportFrame.CurrentCamera = Camera

		local CloneItem = v:Clone()
		CloneItem.Parent = Camera
		CloneItem.CFrame = CloneItem["CameraFrame"].Value
		
		local DefaultCameraSpin = 2
		if CloneItem:FindFirstChild("CameraSpin") then
			DefaultCameraSpin = CloneItem["CameraSpin"].Value
		end
		if CloneItem:FindFirstChild("CameraSize") then
			CloneItem.Size = CloneItem["CameraSize"].Value
		end
		
		RunService.Heartbeat:Connect(function()
			if CloneItem:FindFirstChild("IsYAxis") and CloneItem:FindFirstChild("IsYAxis").Value == true then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(0, math.rad(DefaultCameraSpin), 0)
			elseif CloneItem:FindFirstChild("IsXAxis") and CloneItem:FindFirstChild("IsXAxis").Value == true then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(math.rad(DefaultCameraSpin), 0, 0)
			elseif CloneItem:FindFirstChild("IsZAxis") and CloneItem:FindFirstChild("IsZAxis").Value == true then
				CloneItem.CFrame = CloneItem.CFrame * CFrame.fromEulerAnglesXYZ(0, 0, math.rad(DefaultCameraSpin))
			end
		end)
		
		CloneCell.MouseEnter:Connect(function()
			local Tween1PropertyTable = {Position = Vector3.new(CloneItem.Position.X, CloneItem.Position.Y + 0.15, CloneItem.Position.Z)}
			local Tween2PropertyTable = {Position = CloneItem["CameraFrame"].Value.Position}
			
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
			for Index2, Value2 : Tween in pairs(CellTweens) do
				if Value2.PlaybackState == Enum.PlaybackState.Playing then
					Value2.Completed:Wait()
				end
			end
			task.wait(CellColorChangeDuration)
			
			CellTweens.ToDefault:Play()
		end)
		
		CloneCell.InputBegan:Connect(function(Input)
			CellTweens.ToDefault:Pause()
			
			if Input.UserInputType == Enum.UserInputType.MouseButton1 then
				if Tools:FindFirstChild(CloneItem.Name) then
					local Price = CloneItem["Price"]
					PurchaseAmount:FireServer("Cash", Price.Value)
					
					PurchaseAmount.OnClientEvent:Connect(function(Succeed)
						if Succeed then
							GiveTool:FireServer(CloneItem.Name)
							CellTweens.ToSucceed:Play()
						else warn("Insufficient cash! POOR!") CellTweens.ToFail:Play() end
					end)
				else warn("Requested item is out of stock") CellTweens.ToNoStock:Play() end
			end
		end)
	end

	CloneGUI.Enabled = true
	CloneGUI.Parent = script.Parent
end

InteractShop.OnClientEvent:Connect(GenerateGUI)
RemoveShop.OnClientEvent:Connect(DestroyGUI)
