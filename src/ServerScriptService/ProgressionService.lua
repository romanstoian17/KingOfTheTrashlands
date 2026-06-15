local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ProgressionDefinitions = require(ReplicatedStorage.Modules.ProgressionDefinitions)

local ProgressionService = {
	CombatFeedback = nil,
}

function ProgressionService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")

	Players.PlayerAdded:Connect(function(player)
		self:SetupPlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:SetupPlayer(player)
	end
end

function ProgressionService:SetupPlayer(player)
	self:EnsureCurrencies(player)
	self:GrantSessionDailyReward(player)
end

function ProgressionService:EnsureCurrencies(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	for currencyName in pairs(ProgressionDefinitions.Currencies) do
		if not leaderstats:FindFirstChild(currencyName) then
			local value = Instance.new("IntValue")
			value.Name = currencyName
			value.Value = 0
			value.Parent = leaderstats
		end
	end
end

function ProgressionService:GrantSessionDailyReward(player)
	if player:GetAttribute("DailyRewardClaimedThisSession") then
		return
	end

	player:SetAttribute("DailyRewardClaimedThisSession", true)
	local rewards = ProgressionDefinitions.Rewards.Daily
	self:GrantCurrencyBundle(player, rewards, "Daily reward")
end

function ProgressionService:GrantCurrencyBundle(player, rewards, reason)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		return
	end

	for currencyName, amount in pairs(rewards) do
		local currency = leaderstats:FindFirstChild(currencyName)
		if currency and amount > 0 then
			currency.Value += amount
			if currencyName == "TrashCoins" and self.CombatFeedback then
				self.CombatFeedback:FireClient(player, "Reward", amount, reason or currencyName)
			end
		end
	end
end

return ProgressionService
