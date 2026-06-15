local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
local AnalyticsService = require(ServerScriptService.AnalyticsService)
local CombatService = require(ServerScriptService.CombatService)
local NPCFactory = require(ServerScriptService.NPCFactory)
local SafeZoneService = require(ServerScriptService.SafeZoneService)

local MobService = {
	MobsFolder = nil,
	CombatFeedback = nil,
}

function MobService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")

	self.MobsFolder = Workspace:FindFirstChild("Mobs") or Instance.new("Folder")
	self.MobsFolder.Name = "Mobs"
	self.MobsFolder.Parent = Workspace

	local spawns = Workspace:WaitForChild("MobSpawns"):GetChildren()
	for index, spawnPart in ipairs(spawns) do
		if spawnPart:IsA("BasePart") then
			self:SpawnMob(index, spawnPart)
		end
	end
end

function MobService:SpawnMob(index, spawnPart)
	local definition = self:GetMobDefinition(index)
	local model, humanoid = NPCFactory:CreateHumanoidNPC(definition.Name .. " " .. index, spawnPart.CFrame + Vector3.new(0, 2.5, 0), definition.Color, definition.MaxHealth, definition.Scale)
	model:SetAttribute("IsMob", true)
	model:SetAttribute("RewardCurrency", definition.RewardCurrency)
	model.Parent = self.MobsFolder
	humanoid.WalkSpeed = definition.WalkSpeed

	local lastAttack = 0
	local lastHealth = humanoid.Health
	local alive = true
	local attackWindingUp = false

	humanoid.HealthChanged:Connect(function(health)
		if health < lastHealth then
			self:ShowHitReaction(model)
		end
		lastHealth = health
	end)

	humanoid.Died:Connect(function()
		alive = false
		self:RewardContributors(model)
		CombatService:ClearDamageLedger(model)
		task.delay(Config.Mobs.RespawnSeconds, function()
			if spawnPart.Parent then
				self:SpawnMob(index, spawnPart)
			end
		end)
		task.delay(3, function()
			if model.Parent then
				model:Destroy()
			end
		end)
	end)

	task.spawn(function()
		while alive and model.Parent do
			local mobRoot = model.PrimaryPart
			if not mobRoot then
				return
			end

			local distanceFromSpawn = (mobRoot.Position - spawnPart.Position).Magnitude
			local targetPlayer = distanceFromSpawn <= definition.LeashRadius and self:FindTarget(mobRoot.Position, definition.DetectRadius) or nil
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					humanoid:MoveTo(targetRoot.Position)

					local distance = (targetRoot.Position - mobRoot.Position).Magnitude
					if distance <= definition.AttackRadius and not attackWindingUp and os.clock() - lastAttack >= definition.AttackCooldown then
						lastAttack = os.clock()
						attackWindingUp = true
						self:ShowAttackWindup(model)
						task.delay(Config.Mobs.AttackWindupSeconds, function()
							attackWindingUp = false
							if not alive or not model.Parent or not targetPlayer.Character or not model.PrimaryPart then
								return
							end

							local currentTargetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
							if currentTargetRoot and (currentTargetRoot.Position - model.PrimaryPart.Position).Magnitude <= definition.AttackRadius + 1 then
								CombatService:DamagePlayerFromNPC(targetPlayer, definition.ContactDamage)
							end
						end)
					end
				end
			else
				humanoid:MoveTo(self:GetPatrolPoint(spawnPart.Position, index))
			end

			task.wait(0.35)
		end
	end)
end

function MobService:GetMobDefinition(index)
	if index <= 3 then
		return {
			Name = "Subway Nibbler",
			Color = Color3.fromRGB(105, 170, 255),
			MaxHealth = 55,
			ContactDamage = 6,
			DetectRadius = 58,
			AttackRadius = 6,
			AttackCooldown = 1.9,
			LeashRadius = 75,
			WalkSpeed = 6,
			RewardCurrency = 5,
			Scale = 0.78,
		}
	end

	if index % 4 == 0 then
		return {
			Name = "Scrap Brute",
			Color = Color3.fromRGB(205, 90, 80),
			MaxHealth = 145,
			ContactDamage = 14,
			DetectRadius = 72,
			AttackRadius = 8,
			AttackCooldown = 2.2,
			LeashRadius = 90,
			WalkSpeed = 5.5,
			RewardCurrency = 14,
			Scale = 1.25,
		}
	end

	return {
		Name = "Subway Scrapper",
		Color = Color3.fromRGB(155, 93, 255),
		MaxHealth = Config.Mobs.MaxHealth,
		ContactDamage = Config.Mobs.ContactDamage,
		DetectRadius = Config.Mobs.DetectRadius,
		AttackRadius = Config.Mobs.AttackRadius,
		AttackCooldown = Config.Mobs.AttackCooldown,
		LeashRadius = Config.Mobs.LeashRadius,
		WalkSpeed = Config.Mobs.WalkSpeed,
		RewardCurrency = Config.Mobs.RewardCurrency,
		Scale = 1,
	}
end

function MobService:GetPatrolPoint(spawnPosition, index)
	local angle = os.clock() * 0.28 + index
	local radius = 8 + (index % 3) * 4
	return spawnPosition + Vector3.new(math.cos(angle) * radius, 0, math.sin(angle) * radius)
end

function MobService:ShowAttackWindup(model)
	local root = model.PrimaryPart
	if not root then
		return
	end

	local warning = Instance.new("Part")
	warning.Name = "Mob Attack Windup"
	warning.Anchored = true
	warning.CanCollide = false
	warning.Shape = Enum.PartType.Ball
	warning.Material = Enum.Material.Neon
	warning.Color = Color3.fromRGB(255, 120, 70)
	warning.Transparency = 0.45
	warning.Size = Vector3.new(5, 5, 5)
	warning.CFrame = root.CFrame
	warning.Parent = Workspace
	Debris:AddItem(warning, Config.Mobs.AttackWindupSeconds)
end

function MobService:ShowHitReaction(model)
	local root = model.PrimaryPart
	if not root then
		return
	end

	local flash = Instance.new("Part")
	flash.Name = "Mob Hit Reaction"
	flash.Anchored = true
	flash.CanCollide = false
	flash.Shape = Enum.PartType.Ball
	flash.Material = Enum.Material.Neon
	flash.Color = Color3.fromRGB(255, 245, 160)
	flash.Transparency = 0.35
	flash.Size = Vector3.new(4, 4, 4)
	flash.CFrame = root.CFrame
	flash.Parent = Workspace
	Debris:AddItem(flash, 0.14)
end

function MobService:RewardContributors(mobModel)
	local ledger = CombatService:GetDamageLedger(mobModel)
	local reward = mobModel:GetAttribute("RewardCurrency") or Config.Mobs.RewardCurrency or 0
	if reward <= 0 then
		return
	end

	local rewardedContributor = false
	for userId, damage in pairs(ledger) do
		if damage > 0 then
			local player = Players:GetPlayerByUserId(userId)
			local leaderstats = player and player:FindFirstChild("leaderstats")
			local currency = leaderstats and leaderstats:FindFirstChild("TrashCoins")
			if currency then
				currency.Value += reward
				rewardedContributor = true
				if self.CombatFeedback then
					self.CombatFeedback:FireClient(player, "Reward", reward, "Mob defeated")
				end
			end
		end
	end

	if rewardedContributor then
		AnalyticsService:RecordEvent("MobDefeated")
	end
end

function MobService:FindTarget(position, detectRadius)
	local bestPlayer = nil
	local bestDistance = detectRadius or Config.Mobs.DetectRadius

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

return MobService
