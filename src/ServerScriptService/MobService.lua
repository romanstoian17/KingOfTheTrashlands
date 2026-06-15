local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
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
	local model, humanoid = NPCFactory:CreateHumanoidNPC("Subway Scrapper " .. index, spawnPart.CFrame + Vector3.new(0, 2.5, 0), Color3.fromRGB(155, 93, 255), Config.Mobs.MaxHealth, 1)
	model:SetAttribute("IsMob", true)
	model.Parent = self.MobsFolder
	humanoid.WalkSpeed = Config.Mobs.WalkSpeed

	local lastAttack = 0
	local alive = true
	local attackWindingUp = false

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
			local targetPlayer = distanceFromSpawn <= Config.Mobs.LeashRadius and self:FindTarget(mobRoot.Position) or nil
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					humanoid:MoveTo(targetRoot.Position)

					local distance = (targetRoot.Position - mobRoot.Position).Magnitude
					if distance <= Config.Mobs.AttackRadius and not attackWindingUp and os.clock() - lastAttack >= Config.Mobs.AttackCooldown then
						lastAttack = os.clock()
						attackWindingUp = true
						self:ShowAttackWindup(model)
						task.delay(Config.Mobs.AttackWindupSeconds, function()
							attackWindingUp = false
							if not alive or not model.Parent or not targetPlayer.Character or not model.PrimaryPart then
								return
							end

							local currentTargetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
							if currentTargetRoot and (currentTargetRoot.Position - model.PrimaryPart.Position).Magnitude <= Config.Mobs.AttackRadius + 1 then
								CombatService:DamagePlayerFromNPC(targetPlayer, Config.Mobs.ContactDamage)
							end
						end)
					end
				end
			else
				humanoid:MoveTo(spawnPart.Position)
			end

			task.wait(0.35)
		end
	end)
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

function MobService:RewardContributors(mobModel)
	local ledger = CombatService:GetDamageLedger(mobModel)
	local reward = Config.Mobs.RewardCurrency or 0
	if reward <= 0 then
		return
	end

	for userId, damage in pairs(ledger) do
		if damage > 0 then
			local player = Players:GetPlayerByUserId(userId)
			local leaderstats = player and player:FindFirstChild("leaderstats")
			local currency = leaderstats and leaderstats:FindFirstChild("TrashCoins")
			if currency then
				currency.Value += reward
				if self.CombatFeedback then
					self.CombatFeedback:FireClient(player, "Reward", reward, "Mob defeated")
				end
			end
		end
	end
end

function MobService:FindTarget(position)
	local bestPlayer = nil
	local bestDistance = Config.Mobs.DetectRadius

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
