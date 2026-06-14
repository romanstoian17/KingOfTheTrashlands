local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Workspace = game:GetService("Workspace")

local AbilityDefinitions = require(ReplicatedStorage.Modules.AbilityDefinitions)
local CombatService = require(ServerScriptService.CombatService)

local SpellService = {
	Cooldowns = {},
	CombatFeedback = nil,
}

function SpellService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local castSpell = remotes:WaitForChild("CastSpell")
	local castAbility = remotes:WaitForChild("CastAbility")
	self.CombatFeedback = remotes:WaitForChild("CombatFeedback")
	castSpell.OnServerEvent:Connect(function(player, spellName, aimPosition)
		self:CastAbility(player, spellName, aimPosition)
	end)
	castAbility.OnServerEvent:Connect(function(player, abilityName, aimPosition)
		self:CastAbility(player, abilityName, aimPosition)
	end)
end

function SpellService:IsReady(player, abilityName, cooldown)
	local userCooldowns = self.Cooldowns[player.UserId]
	if not userCooldowns then
		userCooldowns = {}
		self.Cooldowns[player.UserId] = userCooldowns
	end

	local now = os.clock()
	if userCooldowns[abilityName] and now < userCooldowns[abilityName] then
		return false
	end

	userCooldowns[abilityName] = now + cooldown
	return true
end

function SpellService:ResetPlayerCooldowns(player)
	if player then
		self.Cooldowns[player.UserId] = nil
	end
end

function SpellService:PlayerHasAbility(player, abilityName)
	local abilityList = player and (player:FindFirstChild("AbilityList") or player:FindFirstChild("SpellList"))
	if not abilityList then
		return false
	end

	for _, abilityValue in ipairs(abilityList:GetChildren()) do
		if abilityValue:IsA("StringValue") and abilityValue.Value == abilityName then
			return true
		end
	end

	return false
end

function SpellService:PlayerHasSpell(player, spellName)
	return self:PlayerHasAbility(player, spellName)
end

function SpellService:CastAbility(player, abilityName, aimPosition)
	local definition = AbilityDefinitions[abilityName]
	if not definition then
		return false
	end

	if not self:PlayerHasAbility(player, abilityName) then
		return false
	end

	if not self:IsReady(player, abilityName, definition.Cooldown) then
		return false
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return false
	end

	if self.CombatFeedback then
		self.CombatFeedback:FireClient(player, "SpellCooldown", abilityName, definition.Cooldown)
		self.CombatFeedback:FireClient(player, "AbilityCast", abilityName)
	end

	local targeting = definition.Targeting or "ForwardRay"
	if targeting == "ForwardRay" then
		return self:CastForwardRay(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "SelfArea" then
		return self:CastSelfArea(player, character, root, abilityName, definition)
	elseif targeting == "SelfBuff" then
		return self:CastSelfBuff(player, character, abilityName, definition)
	end

	return self:CastUnsupportedAbility(player, abilityName, definition)
end

function SpellService:CastForwardRay(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 2.5, 0)
	local direction = self:GetAimDirection(root, origin, aimPosition) * definition.Range
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	params.FilterDescendantsInstances = { character }

	local result = Workspace:Raycast(origin, direction, params)
	local endPosition = origin + direction
	if result then
		endPosition = result.Position
	end

	self:ShowSpellEffect(origin, endPosition, definition)

	if result and result.Instance then
		local targetCharacter = CombatService:GetHumanoidModelFromPart(result.Instance)
		if targetCharacter then
			local damaged = CombatService:DamageCharacter(player, targetCharacter, definition.Damage, abilityName)
			if damaged then
				self:ApplyAbilityEffects(player, targetCharacter, definition)
			end
			return damaged
		end
	end

	return true
end

function SpellService:CastSelfArea(player, character, root, abilityName, definition)
	local radius = definition.Radius or definition.Range or 20
	local origin = root.Position
	local hitCharacters = {}

	for _, part in ipairs(Workspace:GetPartBoundsInRadius(origin, radius)) do
		local targetCharacter, targetHumanoid = CombatService:GetHumanoidModelFromPart(part)
		if targetCharacter and targetHumanoid and targetHumanoid.Health > 0 and targetCharacter ~= character and not hitCharacters[targetCharacter] then
			hitCharacters[targetCharacter] = true
		end
	end

	local hitSomething = false
	for targetCharacter in pairs(hitCharacters) do
		local damaged = CombatService:DamageCharacter(player, targetCharacter, definition.Damage or 0, abilityName)
		if damaged then
			hitSomething = true
			self:ApplyAbilityEffects(player, targetCharacter, definition)
		end
	end

	self:ShowAreaEffect(origin, radius, definition)
	return hitSomething
end

function SpellService:CastSelfBuff(player, character, abilityName, definition)
	local duration = definition.Duration or 4
	local expiresAt = os.clock() + duration

	character:SetAttribute("ActiveSelfBuff", abilityName)
	character:SetAttribute("ActiveSelfBuffExpiresAt", expiresAt)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid and definition.HealthShield and definition.HealthShield > 0 then
		humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + definition.HealthShield)
	end

	if definition.WalkSpeedMultiplier and humanoid then
		local originalWalkSpeed = humanoid.WalkSpeed
		humanoid.WalkSpeed = originalWalkSpeed * definition.WalkSpeedMultiplier

		task.delay(duration, function()
			if humanoid.Parent and character:GetAttribute("ActiveSelfBuffExpiresAt") == expiresAt then
				humanoid.WalkSpeed = originalWalkSpeed
			end
		end)
	end

	task.delay(duration, function()
		if character.Parent and character:GetAttribute("ActiveSelfBuffExpiresAt") == expiresAt then
			character:SetAttribute("ActiveSelfBuff", nil)
			character:SetAttribute("ActiveSelfBuffExpiresAt", nil)
		end
	end)

	self:ShowBuffEffect(character, definition)
	return true
end

function SpellService:CastSpell(player, spellName)
	return self:CastAbility(player, spellName)
end

function SpellService:GetAimDirection(root, origin, aimPosition)
	if typeof(aimPosition) == "Vector3" then
		local aimOffset = aimPosition - origin
		if aimOffset.Magnitude > 0.01 then
			return aimOffset.Unit
		end
	end

	return root.CFrame.LookVector
end

function SpellService:CastUnsupportedAbility(player, abilityName, definition)
	warn(("Ability %s has unsupported targeting mode %s."):format(abilityName, tostring(definition.Targeting)))
	return false
end

function SpellService:ApplyAbilityEffects(attackerPlayer, targetCharacter, definition)
	for _, effect in ipairs(definition.Effects or {}) do
		-- Effects are intentionally data-first. A future StatusEffectService can
		-- consume this table for burn, slow, bleed, shields, knockback, and more.
		targetCharacter:SetAttribute("LastAbilityEffect", effect.Type or "Effect")
		targetCharacter:SetAttribute("LastAbilityEffectSourceUserId", attackerPlayer.UserId)
	end
end

function SpellService:ShowSpellEffect(origin, endPosition, definition)
	local distance = (endPosition - origin).Magnitude
	local midpoint = origin:Lerp(endPosition, 0.5)
	local visual = definition.Visual or {}
	local width = visual.Width or 0.7
	local lifetime = visual.Lifetime or 0.14
	local material = visual.Material or Enum.Material.Neon
	local shape = visual.Shape or "Beam"

	local bolt = Instance.new("Part")
	bolt.Name = definition.DisplayName .. " Effect"
	bolt.Anchored = true
	bolt.CanCollide = false
	bolt.Material = material
	bolt.Color = definition.Color
	bolt.Size = Vector3.new(width, width, math.max(distance, 1))
	bolt.CFrame = CFrame.lookAt(midpoint, endPosition)
	bolt.Parent = Workspace

	if shape == "Shard" then
		bolt.Shape = Enum.PartType.Block
		bolt.Size = Vector3.new(width * 1.8, width * 0.8, math.max(distance, 1))
	elseif shape == "Spark" then
		bolt.Shape = Enum.PartType.Ball
		bolt.Size = Vector3.new(width * 3, width * 3, width * 3)
		bolt.CFrame = CFrame.new(endPosition)
	elseif shape == "Lightning" then
		local secondary = Instance.new("Part")
		secondary.Name = definition.DisplayName .. " Secondary Effect"
		secondary.Anchored = true
		secondary.CanCollide = false
		secondary.Material = material
		secondary.Color = visual.SecondaryColor or Color3.new(1, 1, 1)
		secondary.Size = Vector3.new(width * 0.45, width * 0.45, math.max(distance, 1))
		secondary.CFrame = CFrame.lookAt(midpoint + Vector3.new(0, width * 1.5, 0), endPosition)
		secondary.Parent = Workspace
		Debris:AddItem(secondary, lifetime)
	end

	if visual.SecondaryColor and shape ~= "Lightning" then
		local core = Instance.new("Part")
		core.Name = definition.DisplayName .. " Core Effect"
		core.Anchored = true
		core.CanCollide = false
		core.Material = Enum.Material.Neon
		core.Color = visual.SecondaryColor
		core.Size = Vector3.new(width * 0.35, width * 0.35, math.max(distance, 1))
		core.CFrame = CFrame.lookAt(midpoint, endPosition)
		core.Parent = Workspace
		Debris:AddItem(core, lifetime)
	end

	Debris:AddItem(bolt, lifetime)
end

function SpellService:ShowAreaEffect(origin, radius, definition)
	local visual = definition.Visual or {}
	local ring = Instance.new("Part")
	ring.Name = definition.DisplayName .. " Area Effect"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = definition.Color
	ring.Transparency = visual.Transparency or 0.45
	ring.Size = Vector3.new(visual.Height or 0.35, radius * 2, radius * 2)
	ring.CFrame = CFrame.new(origin + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace

	if visual.SecondaryColor then
		local inner = Instance.new("Part")
		inner.Name = definition.DisplayName .. " Inner Area Effect"
		inner.Anchored = true
		inner.CanCollide = false
		inner.Shape = Enum.PartType.Cylinder
		inner.Material = Enum.Material.Neon
		inner.Color = visual.SecondaryColor
		inner.Transparency = math.clamp((visual.Transparency or 0.45) + 0.2, 0, 1)
		inner.Size = Vector3.new((visual.Height or 0.35) * 0.7, radius * 1.15, radius * 1.15)
		inner.CFrame = ring.CFrame
		inner.Parent = Workspace
		Debris:AddItem(inner, visual.Lifetime or 0.25)
	end

	Debris:AddItem(ring, visual.Lifetime or 0.25)
end

function SpellService:ShowBuffEffect(character, definition)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local visual = definition.Visual or {}
	local aura = Instance.new("Part")
	aura.Name = definition.DisplayName .. " Buff Effect"
	aura.Anchored = true
	aura.CanCollide = false
	aura.Shape = Enum.PartType.Ball
	aura.Material = visual.Material or Enum.Material.ForceField
	aura.Color = definition.Color
	aura.Transparency = visual.Transparency or 0.55
	aura.Size = visual.Size or Vector3.new(7, 7, 7)
	aura.CFrame = root.CFrame
	aura.Parent = Workspace

	if visual.SecondaryColor then
		local core = Instance.new("Part")
		core.Name = definition.DisplayName .. " Buff Core Effect"
		core.Anchored = true
		core.CanCollide = false
		core.Shape = Enum.PartType.Ball
		core.Material = Enum.Material.Neon
		core.Color = visual.SecondaryColor
		core.Transparency = math.clamp((visual.Transparency or 0.55) + 0.15, 0, 1)
		core.Size = (visual.Size or Vector3.new(7, 7, 7)) * 0.55
		core.CFrame = root.CFrame
		core.Parent = Workspace
		Debris:AddItem(core, visual.Lifetime or 0.35)
	end

	Debris:AddItem(aura, visual.Lifetime or 0.35)
end

Players.PlayerRemoving:Connect(function(player)
	SpellService.Cooldowns[player.UserId] = nil
end)

return SpellService
