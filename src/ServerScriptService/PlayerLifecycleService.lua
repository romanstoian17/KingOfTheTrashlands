local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)
local CombatService = require(ServerScriptService.CombatService)
local SpellService = require(ServerScriptService.SpellService)

local PlayerLifecycleService = {
	AssignedBases = {},
	NextBaseIndex = 1,
	CombatFeedback = nil,
}

function PlayerLifecycleService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")

	Players.PlayerAdded:Connect(function(player)
		self:SetupPlayer(player)
	end)

	Players.PlayerRemoving:Connect(function(player)
		self:ReleaseBase(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:SetupPlayer(player)
	end
end

function PlayerLifecycleService:SetupPlayer(player)
	if player:GetAttribute("LifecycleSetupComplete") then
		return
	end

	player:SetAttribute("LifecycleSetupComplete", true)
	self:AssignHomeBase(player)
	self:SetupStats(player)

	player.CharacterAdded:Connect(function(character)
		self:OnCharacterAdded(player, character)
	end)

	if player.Character then
		self:OnCharacterAdded(player, player.Character)
	end
end

function PlayerLifecycleService:SetupStats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	if not leaderstats:FindFirstChild("Kills") then
		local kills = Instance.new("IntValue")
		kills.Name = "Kills"
		kills.Value = 0
		kills.Parent = leaderstats
	end

	if not leaderstats:FindFirstChild("Deaths") then
		local deaths = Instance.new("IntValue")
		deaths.Name = "Deaths"
		deaths.Value = 0
		deaths.Parent = leaderstats
	end

	if not leaderstats:FindFirstChild("TrashCoins") then
		local currency = Instance.new("IntValue")
		currency.Name = "TrashCoins"
		currency.Value = 0
		currency.Parent = leaderstats
	end
end

function PlayerLifecycleService:AssignHomeBase(player)
	if player:GetAttribute("HomeBaseIndex") then
		return
	end

	local baseIndex = self:FindAvailableBaseIndex()
	self.AssignedBases[player.UserId] = baseIndex
	player:SetAttribute("HomeBaseIndex", baseIndex)

	local spawnLocation = self:GetBaseSpawn(baseIndex)
	if spawnLocation then
		player.RespawnLocation = spawnLocation
		spawnLocation:SetAttribute("OwnerUserId", player.UserId)
	end
end

function PlayerLifecycleService:FindAvailableBaseIndex()
	for _ = 1, Config.Map.BaseCount do
		local baseIndex = self.NextBaseIndex
		self.NextBaseIndex = (self.NextBaseIndex % Config.Map.BaseCount) + 1

		if not self:IsBaseAssigned(baseIndex) then
			return baseIndex
		end
	end

	local fallback = self.NextBaseIndex
	self.NextBaseIndex = (self.NextBaseIndex % Config.Map.BaseCount) + 1
	return fallback
end

function PlayerLifecycleService:IsBaseAssigned(baseIndex)
	for _, assignedBaseIndex in pairs(self.AssignedBases) do
		if assignedBaseIndex == baseIndex then
			return true
		end
	end

	return false
end

function PlayerLifecycleService:GetBaseSpawn(baseIndex)
	local bases = Workspace:WaitForChild("Bases")
	local baseFolder = bases:FindFirstChild("Base " .. baseIndex)
	if not baseFolder then
		return nil
	end

	return baseFolder:FindFirstChild("Base " .. baseIndex .. " Spawn")
end

function PlayerLifecycleService:OnCharacterAdded(player, character)
	local humanoid = character:WaitForChild("Humanoid")
	local root = character:WaitForChild("HumanoidRootPart")

	SpellService:ResetPlayerCooldowns(player)
	self:MoveCharacterToHomeBase(player, character, root)
	self:ApplyRespawnProtection(player)

	humanoid.Died:Connect(function()
		self:OnCharacterDied(player, character)
	end)
end

function PlayerLifecycleService:MoveCharacterToHomeBase(player, character, root)
	local baseIndex = player:GetAttribute("HomeBaseIndex")
	local spawnLocation = baseIndex and self:GetBaseSpawn(baseIndex)
	if not spawnLocation then
		return
	end

	character:PivotTo(spawnLocation.CFrame + Vector3.new(0, 4, 0))
	root.AssemblyLinearVelocity = Vector3.zero
	root.AssemblyAngularVelocity = Vector3.zero
end

function PlayerLifecycleService:ApplyRespawnProtection(player)
	local protectedUntil = os.clock() + Config.Combat.RespawnProtectionSeconds
	local exitProtectedUntil = os.clock() + Config.Combat.ExitProtectionSeconds
	player:SetAttribute("RespawnProtectedUntil", protectedUntil)
	player:SetAttribute("ExitProtectedUntil", exitProtectedUntil)

	local character = player.Character
	local forceField = character and Instance.new("ForceField")
	if forceField then
		forceField.Visible = true
		forceField.Parent = character
	end

	task.delay(Config.Combat.RespawnProtectionSeconds, function()
		if player.Parent and player:GetAttribute("RespawnProtectedUntil") == protectedUntil then
			player:SetAttribute("RespawnProtectedUntil", nil)
		end

		if forceField and forceField.Parent then
			forceField:Destroy()
		end
	end)
end

function PlayerLifecycleService:OnCharacterDied(player, character)
	local leaderstats = player:FindFirstChild("leaderstats")
	local deaths = leaderstats and leaderstats:FindFirstChild("Deaths")
	if deaths then
		deaths.Value += 1
	end

	local killer = CombatService:GetKillCreditPlayer(character)
	if killer and killer ~= player then
		local killerStats = killer:FindFirstChild("leaderstats")
		local kills = killerStats and killerStats:FindFirstChild("Kills")
		if kills then
			kills.Value += 1
		end
	end

	self:PublishDeathFeedback(player, killer, character)
	SpellService:ResetPlayerCooldowns(player)
end

function PlayerLifecycleService:PublishDeathFeedback(player, killer, character)
	if not self.CombatFeedback then
		return
	end

	local killerName = killer and killer.DisplayName or nil
	local sourceName = character and character:GetAttribute("LastHitSource") or nil
	self.CombatFeedback:FireClient(player, "Death", killerName, sourceName or "", Config.Combat.DeathMessageSeconds)
end

function PlayerLifecycleService:ReleaseBase(player)
	local baseIndex = self.AssignedBases[player.UserId]
	self.AssignedBases[player.UserId] = nil

	if baseIndex then
		local spawnLocation = self:GetBaseSpawn(baseIndex)
		if spawnLocation then
			spawnLocation:SetAttribute("OwnerUserId", nil)
		end
	end
end

return PlayerLifecycleService
