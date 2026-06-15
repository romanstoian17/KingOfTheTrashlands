local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
local CombatService = require(ServerScriptService.CombatService)
local ProgressionDefinitions = require(ReplicatedStorage.Modules.ProgressionDefinitions)
local ProgressionService = require(ServerScriptService.ProgressionService)
local AnalyticsService = require(ServerScriptService.AnalyticsService)
local NPCFactory = require(ServerScriptService.NPCFactory)
local SafeZoneService = require(ServerScriptService.SafeZoneService)

local BossTypes = {
	{
		Name = "Trash Titan",
		Color = Color3.fromRGB(255, 78, 52),
		Scale = 2.4,
		HealthMultiplier = 1,
		DamageMultiplier = 1,
	},
	{
		Name = "Junk Colossus",
		Color = Color3.fromRGB(215, 145, 75),
		Scale = 2.7,
		HealthMultiplier = 1.2,
		DamageMultiplier = 1.05,
	},
	{
		Name = "Subway Horror",
		Color = Color3.fromRGB(160, 70, 255),
		Scale = 2.25,
		HealthMultiplier = 0.9,
		DamageMultiplier = 1.15,
	},
}

local BossService = {
	CurrentBoss = nil,
	BossAlert = nil,
	CombatFeedback = nil,
}

function BossService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.BossAlert = remotes:WaitForChild("BossAlert")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")

	task.spawn(function()
		self:WaitWithWarning(Config.Boss.InitialSpawnSeconds)
		self:SpawnBoss("Center Arena")
		self:RunBossLoop()
	end)
end

function BossService:RunBossLoop()
	while true do
		local delaySeconds = math.random(Config.Boss.SpawnMinSeconds, Config.Boss.SpawnMaxSeconds)
		local locationName = self:ChooseBossLocation()
		self:WaitWithWarning(delaySeconds, locationName)

		if not self.CurrentBoss or not self.CurrentBoss.Parent then
			self:SpawnBoss(locationName)
		end
	end
end

function BossService:WaitWithWarning(delaySeconds, locationName)
	local warningSeconds = math.min(Config.Boss.WarningSeconds, math.max(delaySeconds, 0))
	local quietSeconds = math.max(delaySeconds - warningSeconds, 0)

	if quietSeconds > 0 then
		task.wait(quietSeconds)
	end

	self:PublishBossAlert("Warning", "Trash Titan incoming", locationName or "Center Arena", warningSeconds)

	if warningSeconds > 0 then
		task.wait(warningSeconds)
	end
end

function BossService:PublishBossAlert(alertType, title, locationName, seconds)
	if self.BossAlert then
		self.BossAlert:FireAllClients(alertType, title, locationName, seconds or 0)
	end
end

function BossService:SpawnBoss(locationName)
	local spawnPart = self:GetBossSpawnPart(locationName or "Center Arena")
	if not spawnPart then
		return
	end

	local bossType = self:ChooseBossType(locationName)
	local playerScale = math.max(#Players:GetPlayers() - 1, 0) * 0.18
	local maxHealth = math.floor(Config.Boss.MaxHealth * bossType.HealthMultiplier * (1 + playerScale))
	local contactDamage = math.floor(Config.Boss.ContactDamage * bossType.DamageMultiplier)
	local model, humanoid = NPCFactory:CreateHumanoidNPC(bossType.Name, spawnPart.CFrame + Vector3.new(0, 6, 0), bossType.Color, maxHealth, bossType.Scale)
	model:SetAttribute("IsBoss", true)
	model:SetAttribute("BossLocation", locationName or "Center Arena")
	model.Parent = Workspace
	self.CurrentBoss = model
	self:PublishBossAlert("Spawned", bossType.Name .. " has spawned", locationName or "Center Arena", 0)
	self:PublishBossHealth(model.Name, humanoid.Health, humanoid.MaxHealth, true)

	local alive = true
	local lastAttack = 0
	local attackWindingUp = false

	humanoid.HealthChanged:Connect(function(health)
		if alive then
			self:PublishBossHealth(model.Name, health, humanoid.MaxHealth, true)
		end
	end)

	humanoid.Died:Connect(function()
		alive = false
		self:RewardContributors(model)
		CombatService:ClearDamageLedger(model)
		self:PublishBossAlert("Defeated", bossType.Name .. " defeated", locationName or "Center Arena", 0)
		self:PublishBossHealth(model.Name, 0, humanoid.MaxHealth, false)
		task.delay(5, function()
			if model.Parent then
				model:Destroy()
			end
		end)
	end)

	task.spawn(function()
		while alive and model.Parent do
			local targetPlayer = self:FindTarget(model.PrimaryPart.Position)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					humanoid:MoveTo(targetRoot.Position)

					local distance = (targetRoot.Position - model.PrimaryPart.Position).Magnitude
					if distance <= Config.Boss.AttackRadius and not attackWindingUp and os.clock() - lastAttack >= Config.Boss.AttackCooldown then
						lastAttack = os.clock()
						attackWindingUp = true
						self:ShowAttackTelegraph(model)
						task.delay(0.75, function()
							attackWindingUp = false
							if not alive or not model.Parent or not targetPlayer.Character or not model.PrimaryPart then
								return
							end

							local currentTargetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
							if currentTargetRoot and (currentTargetRoot.Position - model.PrimaryPart.Position).Magnitude <= Config.Boss.AttackRadius + 3 then
								CombatService:DamagePlayerFromNPC(targetPlayer, contactDamage)
							end
						end)
					end
				end
			end

			task.wait(0.4)
		end
	end)
end

function BossService:ChooseBossType(locationName)
	if locationName == "Subway" then
		return BossTypes[math.random(2, #BossTypes)]
	end

	return BossTypes[math.random(1, #BossTypes)]
end

function BossService:ShowAttackTelegraph(model)
	local root = model.PrimaryPart
	if not root then
		return
	end

	local marker = Instance.new("Part")
	marker.Name = "Boss Attack Telegraph"
	marker.Anchored = true
	marker.CanCollide = false
	marker.Shape = Enum.PartType.Cylinder
	marker.Material = Enum.Material.Neon
	marker.Color = Color3.fromRGB(255, 80, 55)
	marker.Transparency = 0.5
	marker.Size = Vector3.new(0.2, Config.Boss.AttackRadius * 2, Config.Boss.AttackRadius * 2)
	marker.CFrame = CFrame.new(root.Position - Vector3.new(0, 2.3, 0)) * CFrame.Angles(0, 0, math.rad(90))
	marker.Parent = Workspace
	game:GetService("Debris"):AddItem(marker, 0.8)
end

function BossService:ChooseBossLocation()
	local options = self:GetBossSpawnOptions()
	if #options == 0 then
		return "Center Arena"
	end

	return options[math.random(1, #options)]
end

function BossService:GetBossSpawnOptions()
	local options = {}
	local bossSpawns = Workspace:FindFirstChild("BossSpawns")
	if not bossSpawns then
		return options
	end

	for _, spawnPart in ipairs(bossSpawns:GetChildren()) do
		if spawnPart:IsA("BasePart") and spawnPart:GetAttribute("BossSpawn") then
			table.insert(options, spawnPart:GetAttribute("LocationName") or "Center Arena")
		end
	end

	return options
end

function BossService:GetBossSpawnPart(locationName)
	local bossSpawns = Workspace:WaitForChild("BossSpawns")
	for _, spawnPart in ipairs(bossSpawns:GetChildren()) do
		if spawnPart:IsA("BasePart") and spawnPart:GetAttribute("BossSpawn") then
			local spawnLocation = spawnPart:GetAttribute("LocationName") or "Center Arena"
			if spawnLocation == locationName then
				return spawnPart
			end
		end
	end

	return bossSpawns:FindFirstChild("CenterBossSpawn")
end

function BossService:PublishBossHealth(bossName, health, maxHealth, isActive)
	if self.CombatFeedback then
		self.CombatFeedback:FireAllClients("BossHealth", bossName, math.max(health or 0, 0), maxHealth or 0, isActive == true)
	end
end

function BossService:FindTarget(position)
	local bestPlayer = nil
	local bestDistance = 150

	for _, player in ipairs(Players:GetPlayers()) do
		if not SafeZoneService:IsPlayerInSafeZone(player) and not SafeZoneService:IsPlayerExitProtected(player) and player.Character then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root then
				local distance = (root.Position - position).Magnitude
				if distance < bestDistance then
					bestDistance = distance
					bestPlayer = player
				end
			end
		end
	end

	return bestPlayer
end

function BossService:RewardContributors(bossModel)
	local ledger = CombatService:GetDamageLedger(bossModel)
	local rewards = ProgressionDefinitions.Rewards.BossContribution or {
		TrashCoins = Config.Boss.RewardCurrency,
	}

	for userId, damage in pairs(ledger) do
		if damage > 0 then
			local player = Players:GetPlayerByUserId(userId)
			if player then
				ProgressionService:GrantCurrencyBundle(player, rewards, "Boss defeated")
				AnalyticsService:RecordEvent("BossParticipation")
			end
		end
	end
end

return BossService
