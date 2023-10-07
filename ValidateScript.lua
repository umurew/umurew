local ServerStorage = game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local Tools = ServerStorage.Tools
local ValidateTool = ReplicatedStorage:FindFirstChild("ValidateTool")

local function OnEvent (Player, ToolName, ToolCost, HashGUID)
	local RespondTable = {
		["Status"] = nil,
		["Message"] = nil
	}

	if Tools:FindFirstChild(ToolName) then
		local Cash = Player:WaitForChild("leaderstats").Cash
		if Cash and Cash.Value >= ToolCost then
			Cash.Value = math.max(0, Cash.Value - ToolCost)

			local Tool = Tools:FindFirstChild(ToolName):Clone()
			Tool.Parent = Player.Backpack

			RespondTable.Status = "Succeed"
			RespondTable.Message = "Succeed!"
		else
			RespondTable.Status = "Fail"
			RespondTable.Message = "Insufficient cash! POOR!"
		end
	else
		RespondTable.Status = "NoStock"
		RespondTable.Message = "Requested item is out of stock!"
	end

	ValidateTool:FireClient(Player, RespondTable, HashGUID)
end

ValidateTool.OnServerEvent:Connect(OnEvent)
