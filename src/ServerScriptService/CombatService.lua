local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Modules.Config)
local SafeZoneService = require(ServerScriptService.SafeZoneService)

local CombatService = {
	DamageLedgers = {},
	CombatFeedback = nil,
}

function CombatService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")
end

function CombatService:IsPlayerRespawnProtected(player)
	local protectedUntil = player and player:GetAttribute("RespawnProtectedUntil")
	return typeof(protectedUntil) == "number" and os.clock() < protectedUntil
end

function CombatService:GetHumanoidModelFromPart(part)
	local current = part
	while current and current ~= workspace do
		local humanoid = current:FindFirstChildOfClass("Humanoid")
		if humanoid then
			return current, humanoid
		end
		current = current.Parent
	end

	return nil, nil
end

function CombatService:CanPlayerDamageCharacter(attackerPlayer, targetCharacter)
	if not attackerPlayer or not attackerPlayer:IsA("Player") then
		return false, "Missing attacker"
	end

	if SafeZoneService:IsPlayerInSafeZone(attackerPlayer) then
		return false, "Attacker is in a safe zone"
	end

	if self:IsPlayerRespawnProtected(attackerPlayer) then
		return false, "Attacker has respawn protection"
	end

	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
	if targetPlayer and SafeZoneService:IsPlayerInSafeZone(targetPlayer) then
		return false, "Target is in a safe zone"
	end

	if targetPlayer and self:IsPlayerRespawnProtected(targetPlayer) then
		return false, "Target has respawn protection"
	end

	return true
end

function CombatService:DamageCharacter(attackerPlayer, targetCharacter, amount, sourceName)
	local humanoid = targetCharacter and targetCharacter:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	local allowed = self:CanPlayerDamageCharacter(attackerPlayer, targetCharacter)
	if not allowed then
		return false
	end

	local damageAmount = math.min(amount, humanoid.Health)
	self:RecordPlayerDamage(attackerPlayer, targetCharacter)
	self:RecordDamage(attackerPlayer, targetCharacter, damageAmount, sourceName)
	humanoid:TakeDamage(amount)
	self:PublishDamageFeedback(attackerPlayer, targetCharacter, damageAmount, sourceName)
	return true
end

function CombatService:DamagePlayerFromNPC(targetPlayer, amount)
	if not targetPlayer or SafeZoneService:IsPlayerInSafeZone(targetPlayer) or self:IsPlayerRespawnProtected(targetPlayer) then
		return false
	end

	local character = targetPlayer.Character
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 then
		return false
	end

	local damageAmount = math.min(amount, humanoid.Health)
	character:SetAttribute("LastDamagedByUserId", nil)
	character:SetAttribute("LastDamagedAt", nil)
	humanoid:TakeDamage(amount)
	self:PublishDamageFeedback(nil, character, damageAmount, "NPC")
	return true
end

function CombatService:PublishDamageFeedback(attackerPlayer, targetCharacter, amount, sourceName)
	if not self.CombatFeedback or not targetCharacter or amount <= 0 then
		return
	end

	self.CombatFeedback:FireAllClients("DamageNumber", targetCharacter, math.floor(amount + 0.5), sourceName or "Damage")

	if attackerPlayer then
		self.CombatFeedback:FireClient(attackerPlayer, "HitConfirm", targetCharacter, math.floor(amount + 0.5), sourceName or "Damage")
	end
end

function CombatService:RecordPlayerDamage(attackerPlayer, targetCharacter)
	local targetPlayer = Players:GetPlayerFromCharacter(targetCharacter)
	if not targetPlayer or targetPlayer == attackerPlayer then
		return
	end

	targetCharacter:SetAttribute("LastDamagedByUserId", attackerPlayer.UserId)
	targetCharacter:SetAttribute("LastDamagedAt", os.clock())
end

function CombatService:GetKillCreditPlayer(character)
	if not character then
		return nil
	end

	local userId = character:GetAttribute("LastDamagedByUserId")
	local damagedAt = character:GetAttribute("LastDamagedAt")
	if typeof(userId) ~= "number" or typeof(damagedAt) ~= "number" then
		return nil
	end

	if os.clock() - damagedAt > Config.Combat.KillCreditSeconds then
		return nil
	end

	return Players:GetPlayerByUserId(userId)
end

function CombatService:RecordDamage(attackerPlayer, targetCharacter, amount, sourceName)
	if not targetCharacter or not attackerPlayer then
		return
	end

	if not targetCharacter:GetAttribute("IsBoss") and not targetCharacter:GetAttribute("IsMob") then
		return
	end

	local ledger = self.DamageLedgers[targetCharacter]
	if not ledger then
		ledger = {}
		self.DamageLedgers[targetCharacter] = ledger
	end

	local userId = attackerPlayer.UserId
	ledger[userId] = (ledger[userId] or 0) + amount
	targetCharacter:SetAttribute("LastHitUserId", userId)
	targetCharacter:SetAttribute("LastHitSource", sourceName or "Unknown")
end

function CombatService:GetDamageLedger(targetCharacter)
	return self.DamageLedgers[targetCharacter] or {}
end

function CombatService:ClearDamageLedger(targetCharacter)
	self.DamageLedgers[targetCharacter] = nil
end

return CombatService
