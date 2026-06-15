local Players = game:GetService("Players")

local AnalyticsService = {
	Counters = {},
	AbilityStats = {},
	Deaths = {},
	DebugEnabled = false,
}

function AnalyticsService:Init()
	self:RecordEvent("ServerStarted")

	Players.PlayerAdded:Connect(function(player)
		self:RecordEvent("PlayerJoined")
		player:SetAttribute("AnalyticsJoinedAt", os.clock())
	end)
end

function AnalyticsService:RecordEvent(eventName, amount)
	self.Counters[eventName] = (self.Counters[eventName] or 0) + (amount or 1)
	if self.DebugEnabled then
		print("[Analytics]", eventName, self.Counters[eventName])
	end
end

function AnalyticsService:RecordClassChoice(className)
	self:RecordEvent("ClassChoice:" .. tostring(className))
end

function AnalyticsService:RecordAbilityCast(abilityName)
	local stats = self:GetAbilityStats(abilityName)
	stats.Casts += 1
end

function AnalyticsService:RecordAbilityDamage(abilityName, amount)
	local stats = self:GetAbilityStats(abilityName)
	stats.Hits += 1
	stats.Damage += amount or 0
end

function AnalyticsService:RecordDeath(player, position)
	self:RecordEvent("PlayerDeath")
	table.insert(self.Deaths, {
		UserId = player and player.UserId or 0,
		Position = position,
		Time = os.clock(),
	})
end

function AnalyticsService:GetAbilityStats(abilityName)
	abilityName = abilityName or "Unknown"
	local stats = self.AbilityStats[abilityName]
	if not stats then
		stats = {
			Casts = 0,
			Hits = 0,
			Damage = 0,
		}
		self.AbilityStats[abilityName] = stats
	end

	return stats
end

return AnalyticsService
