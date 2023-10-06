local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Tools = ReplicatedStorage:WaitForChild("Tools")

local PurchaseAmount = ReplicatedStorage:WaitForChild("PurchaseAmount")
local GiveTool = ReplicatedStorage:WaitForChild("GiveTool")

PurchaseAmount.OnServerEvent:Connect(function(Player, ValueName, Price)
	if not ValueName then
		warn("ValueName missing!")
		return
	elseif not Price then
		warn("Price missing!")
		return
	end
	
	local Leaderstats = Player:FindFirstChild("leaderstats")
	if Leaderstats:FindFirstChild(ValueName) then
		local IntValue = Leaderstats:FindFirstChild(ValueName)
		
		if IntValue.Value >= Price then
			PurchaseAmount:FireClient(Player, true)
			IntValue.Value = math.max(0, IntValue.Value - Price)
		else
			PurchaseAmount:FireClient(Player, false)
		end
	end
end)

GiveTool.OnServerEvent:Connect(function(Player, ToolName)
	if Tools:FindFirstChild(ToolName) then
		local CloneTool = Tools:FindFirstChild(ToolName):Clone()
		CloneTool.Parent = Player:FindFirstChild("Backpack")
	end
end)

Players.PlayerAdded:Connect(function(Player)
	local Leaderstats = Instance.new("Folder", Player)
	local Cash = Instance.new("IntValue", Leaderstats)
	
	Leaderstats.Name = "leaderstats"
	Cash.Name = "Cash"
	
	Cash.Value = math.random(math.random(100, 250), math.random(250, 625))
	print("You got", Cash.Value .. " cash!")
end)
