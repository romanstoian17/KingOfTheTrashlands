local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
local CombatService = require(ServerScriptService.CombatService)
local NPCFactory = require(ServerScriptService.NPCFactory)
local SafeZoneService = require(ServerScriptService.SafeZoneService)

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
		self:WaitWithWarning(delaySeconds)

		if not self.CurrentBoss or not self.CurrentBoss.Parent then
			self:SpawnBoss("Center Arena")
		end
	end
end

function BossService:WaitWithWarning(delaySeconds)
	local warningSeconds = math.min(Config.Boss.WarningSeconds, math.max(delaySeconds, 0))
	local quietSeconds = math.max(delaySeconds - warningSeconds, 0)

	if quietSeconds > 0 then
		task.wait(quietSeconds)
	end

	self:PublishBossAlert("Warning", "Trash Titan incoming", "Center Arena", warningSeconds)

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
	local spawnPart = Workspace:WaitForChild("BossSpawns"):FindFirstChild("CenterBossSpawn")
	if not spawnPart then
		return
	end

	local model, humanoid = NPCFactory:CreateHumanoidNPC("Trash Titan", spawnPart.CFrame + Vector3.new(0, 6, 0), Color3.fromRGB(255, 78, 52), Config.Boss.MaxHealth, 2.4)
	model:SetAttribute("IsBoss", true)
	model.Parent = Workspace
	self.CurrentBoss = model
	self:PublishBossAlert("Spawned", "Trash Titan has spawned", locationName or "Center Arena", 0)
	self:PublishBossHealth(model.Name, humanoid.Health, humanoid.MaxHealth, true)

	local alive = true
	local lastAttack = 0

	humanoid.HealthChanged:Connect(function(health)
		if alive then
			self:PublishBossHealth(model.Name, health, humanoid.MaxHealth, true)
		end
	end)

	humanoid.Died:Connect(function()
		alive = false
		self:RewardContributors(model)
		CombatService:ClearDamageLedger(model)
		self:PublishBossAlert("Defeated", "Trash Titan defeated", locationName or "Center Arena", 0)
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
					if distance <= Config.Boss.AttackRadius and os.clock() - lastAttack >= Config.Boss.AttackCooldown then
						lastAttack = os.clock()
						CombatService:DamagePlayerFromNPC(targetPlayer, Config.Boss.ContactDamage)
					end
				end
			end

			task.wait(0.4)
		end
	end)
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

	for userId, damage in pairs(ledger) do
		if damage > 0 then
			local player = Players:GetPlayerByUserId(userId)
			local leaderstats = player and player:FindFirstChild("leaderstats")
			local currency = leaderstats and leaderstats:FindFirstChild("TrashCoins")
			if currency then
				currency.Value += Config.Boss.RewardCurrency
				if self.CombatFeedback then
					self.CombatFeedback:FireClient(player, "Reward", Config.Boss.RewardCurrency, "Boss defeated")
				end
			end
		end
	end
end

return BossService
