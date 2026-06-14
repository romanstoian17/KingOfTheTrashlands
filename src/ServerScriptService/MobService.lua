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
}

function MobService:Init()
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

	humanoid.Died:Connect(function()
		alive = false
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
			local targetPlayer = self:FindTarget(model.PrimaryPart.Position)
			if targetPlayer and targetPlayer.Character then
				local targetRoot = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
				if targetRoot then
					humanoid:MoveTo(targetRoot.Position)

					local distance = (targetRoot.Position - model.PrimaryPart.Position).Magnitude
					if distance <= Config.Mobs.AttackRadius and os.clock() - lastAttack >= Config.Mobs.AttackCooldown then
						lastAttack = os.clock()
						CombatService:DamagePlayerFromNPC(targetPlayer, Config.Mobs.ContactDamage)
					end
				end
			else
				humanoid:MoveTo(spawnPart.Position)
			end

			task.wait(0.35)
		end
	end)
end

function MobService:FindTarget(position)
	local bestPlayer = nil
	local bestDistance = Config.Mobs.DetectRadius

	for _, player in ipairs(Players:GetPlayers()) do
		if not SafeZoneService:IsPlayerInSafeZone(player) and player.Character then
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
