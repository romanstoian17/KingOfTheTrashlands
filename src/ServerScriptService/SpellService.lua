local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local AbilityDefinitions = require(ReplicatedStorage.Modules.AbilityDefinitions)
local Config = require(ReplicatedStorage.Modules.Config)
local AnalyticsService = require(ServerScriptService.AnalyticsService)
local CombatService = require(ServerScriptService.CombatService)
local NPCFactory = require(ServerScriptService.NPCFactory)
local SafeZoneService = require(ServerScriptService.SafeZoneService)

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

	if not self:IsReady(player, abilityName, definition.Cooldown or 1) then
		return false
	end

	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	if not root or not humanoid or humanoid.Health <= 0 then
		return false
	end

	if self.CombatFeedback then
		self.CombatFeedback:FireClient(player, "SpellCooldown", abilityName, definition.Cooldown or 1)
		self.CombatFeedback:FireClient(player, "AbilityCast", abilityName)
	end

	AnalyticsService:RecordAbilityCast(abilityName)
	self:ShowCastBurst(root.Position, definition)

	local targeting = definition.Targeting or "Raycast"
	if targeting == "ForwardRay" or targeting == "Raycast" then
		return self:CastRaycast(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "MultiRaycast" then
		return self:CastMultiRaycast(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "ProjectileExplode" then
		return self:CastProjectileExplode(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "SelfArea" then
		return self:CastSelfArea(player, character, root, abilityName, definition)
	elseif targeting == "DelayedSelfArea" then
		return self:CastDelayedSelfArea(player, character, root, abilityName, definition)
	elseif targeting == "LineWave" then
		return self:CastLineWave(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "TargetedArea" then
		return self:CastTargetedArea(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "Summon" then
		return self:CastSummon(player, character, root, abilityName, definition, aimPosition)
	elseif targeting == "SelfBuff" then
		return self:CastSelfBuff(player, character, abilityName, definition)
	end

	return self:CastUnsupportedAbility(player, abilityName, definition)
end

function SpellService:MakeRaycastParams(character, extraExclude)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude
	local excluded = { character }
	if extraExclude then
		table.insert(excluded, extraExclude)
	end
	params.FilterDescendantsInstances = excluded
	return params
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

function SpellService:GetClampedAimPoint(root, origin, aimPosition, range)
	local direction = self:GetAimDirection(root, origin, aimPosition)
	return origin + direction * (range or 80), direction
end

function SpellService:CastRaycast(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 2.5, 0)
	local endPoint, direction = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local result = Workspace:Raycast(origin, direction * (definition.Range or 80), self:MakeRaycastParams(character))
	if result then
		endPoint = result.Position
	end

	self:ShowRayEffect(origin, endPoint, definition)

	if result and result.Instance then
		local targetCharacter = CombatService:GetHumanoidModelFromPart(result.Instance)
		if targetCharacter then
			local damaged = CombatService:DamageCharacter(player, targetCharacter, definition.Damage or 0, abilityName)
			if damaged then
				self:ApplyAbilityEffects(player, targetCharacter, definition)
			end
			return damaged
		end
	end

	return true
end

function SpellService:CastProjectileExplode(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 2.4, 0)
	local targetPoint, direction = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local projectile = self:CreateProjectile(origin, direction, definition)
	local speed = definition.ProjectileSpeed or 90
	local maxDistance = definition.Range or 100
	local traveled = 0
	local position = origin
	local hitPosition = targetPoint
	local hit = false
	local params = self:MakeRaycastParams(character, projectile)

	while projectile.Parent and traveled < maxDistance and not hit do
		local dt = task.wait()
		local stepDistance = math.min(speed * dt, maxDistance - traveled)
		local nextPosition = position + direction * stepDistance
		local result = Workspace:Raycast(position, nextPosition - position, params)
		if result then
			hit = true
			hitPosition = result.Position
		else
			hitPosition = nextPosition
		end

		position = hitPosition
		traveled += stepDistance
		projectile.CFrame = CFrame.lookAt(position, position + direction)
	end

	if projectile.Parent then
		projectile:Destroy()
	end

	self:ExplodeAt(player, character, abilityName, definition, hitPosition)
	return true
end

function SpellService:CastSelfArea(player, character, root, abilityName, definition)
	local radius = definition.Radius or definition.Range or 20
	self:DamageCharactersInRadius(player, character, root.Position, radius, definition.Damage or 0, abilityName, definition)
	self:ShowAreaEffect(root.Position, radius, definition)
	return true
end

function SpellService:CastDelayedSelfArea(player, character, root, abilityName, definition)
	local radius = definition.Radius or definition.Range or 24
	local duration = definition.SpreadDuration or 1.4
	local steps = definition.SpreadSteps or 7
	local hitCharacters = {}

	task.spawn(function()
		for step = 1, steps do
			if not character.Parent or not root.Parent then
				return
			end

			local currentRadius = radius * (step / steps)
			self:DamageCharactersInRadius(player, character, root.Position, currentRadius, definition.Damage or 0, abilityName, definition, hitCharacters)
			self:ShowIceNovaStep(root.Position, currentRadius, step, definition)
			task.wait(duration / steps)
		end
	end)

	return true
end

function SpellService:CastLineWave(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 0.6, 0)
	local _, direction = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local range = definition.Range or 75
	local width = definition.Width or 8
	local duration = definition.TravelDuration or 1.8
	local steps = definition.WaveSteps or 10
	local hitCharacters = {}

	task.spawn(function()
		for step = 1, steps do
			if not character.Parent or not root.Parent then
				return
			end

			local distance = range * (step / steps)
			local position = origin + direction * distance
			self:DamageCharactersInRadius(player, character, position, width, definition.Damage or 0, abilityName, definition, hitCharacters)
			self:ShowLineWaveStep(position, direction, step, definition)
			task.wait(duration / steps)
		end
	end)

	return true
end

function SpellService:CastTargetedArea(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 2, 0)
	local targetPoint = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local delaySeconds = definition.Delay or 0.45
	local radius = definition.Radius or 18
	self:ShowTargetWarning(targetPoint, radius, definition, delaySeconds)

	task.delay(delaySeconds, function()
		if character.Parent then
			self:DamageCharactersInRadius(player, character, targetPoint, radius, definition.Damage or 0, abilityName, definition)
			self:ShowAreaEffect(targetPoint, radius, definition)
		end
	end)

	return true
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

function SpellService:CastSummon(player, character, root, abilityName, definition, aimPosition)
	if (Config.VFX.MaxSimultaneousSummonsPerPlayer or 1) <= 1 then
		self:DestroyPlayerSummons(player)
	end

	local origin = root.Position + Vector3.new(0, 2, 0)
	local targetPoint = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local summonPosition = self:GetGroundedPosition(targetPoint)
	local visual = definition.Visual or {}
	local summonName = definition.SummonName or definition.DisplayName or "Summon"
	local model, humanoid = NPCFactory:CreateHumanoidNPC(summonName, CFrame.new(summonPosition + Vector3.new(0, 2.5, 0)), definition.Color or Color3.fromRGB(180, 235, 255), definition.SummonHealth or 120, definition.SummonScale or 0.9)

	model:SetAttribute("IsSummon", true)
	model:SetAttribute("SummonOwnerUserId", player.UserId)
	model:SetAttribute("SummonAbility", abilityName)
	model.Parent = self:GetSummonsFolder()
	humanoid.WalkSpeed = definition.SummonWalkSpeed or 13

	self:ShowSummonEffect(summonPosition, definition)
	self:RunSummonAI(player, model, humanoid, abilityName, definition)

	Debris:AddItem(model, definition.Duration or 18)
	return true
end

function SpellService:CastSpell(player, spellName)
	return self:CastAbility(player, spellName)
end

function SpellService:CastUnsupportedAbility(player, abilityName, definition)
	warn(("Ability %s has unsupported targeting mode %s."):format(abilityName, tostring(definition.Targeting)))
	return false
end

function SpellService:ApplyAbilityEffects(attackerPlayer, targetCharacter, definition)
	for _, effect in ipairs(definition.Effects or {}) do
		targetCharacter:SetAttribute("LastAbilityEffect", effect.Type or "Effect")
		targetCharacter:SetAttribute("LastAbilityEffectSourceUserId", attackerPlayer.UserId)
	end
end

function SpellService:GetSummonsFolder()
	local folder = Workspace:FindFirstChild("Summons")
	if not folder then
		folder = Instance.new("Folder")
		folder.Name = "Summons"
		folder.Parent = Workspace
	end

	return folder
end

function SpellService:CastMultiRaycast(player, character, root, abilityName, definition, aimPosition)
	local origin = root.Position + Vector3.new(0, 2.5, 0)
	local _, direction = self:GetClampedAimPoint(root, origin, aimPosition, definition.Range)
	local spreadDegrees = definition.SpreadDegrees or 8
	local rayCount = definition.RayCount or 3
	local damagePerRay = definition.DamagePerRay or ((definition.Damage or 0) / rayCount)
	local startIndex = -(rayCount - 1) / 2
	local hitCharacters = {}

	for index = 0, rayCount - 1 do
		local yaw = math.rad((startIndex + index) * spreadDegrees)
		local spreadDirection = (CFrame.lookAt(Vector3.zero, direction) * CFrame.Angles(0, yaw, 0)).LookVector
		local result = Workspace:Raycast(origin, spreadDirection * (definition.Range or 80), self:MakeRaycastParams(character))
		local endPoint = result and result.Position or origin + spreadDirection * (definition.Range or 80)

		self:ShowRayEffect(origin, endPoint, definition)

		if result and result.Instance then
			local targetCharacter = CombatService:GetHumanoidModelFromPart(result.Instance)
			if targetCharacter and not hitCharacters[targetCharacter] then
				hitCharacters[targetCharacter] = true
				local damaged = CombatService:DamageCharacter(player, targetCharacter, damagePerRay, abilityName)
				if damaged then
					self:ApplyAbilityEffects(player, targetCharacter, definition)
				end
			end
		end
	end

	return true
end

function SpellService:DestroyPlayerSummons(player)
	if not player then
		return
	end

	local summonsFolder = Workspace:FindFirstChild("Summons")
	if not summonsFolder then
		return
	end

	for _, summon in ipairs(summonsFolder:GetChildren()) do
		if summon:GetAttribute("SummonOwnerUserId") == player.UserId then
			if summon.PrimaryPart then
				self:ShowSummonVanishEffect(summon.PrimaryPart.Position, { DisplayName = summon.Name })
			end
			summon:Destroy()
		end
	end
end

function SpellService:GetGroundedPosition(position)
	local result = Workspace:Raycast(position + Vector3.new(0, 35, 0), Vector3.new(0, -90, 0))
	if result then
		return result.Position
	end

	return position
end

function SpellService:RunSummonAI(ownerPlayer, model, humanoid, abilityName, definition)
	local lifetime = definition.Duration or 18
	local expiresAt = os.clock() + lifetime
	local attackDamage = definition.SummonDamage or definition.Damage or 8
	local attackRadius = definition.SummonAttackRadius or 8
	local detectRadius = definition.SummonDetectRadius or 70
	local attackCooldown = definition.SummonAttackCooldown or 1.3
	local lastAttack = 0

	task.spawn(function()
		while ownerPlayer.Parent and model.Parent and humanoid.Health > 0 and os.clock() < expiresAt do
			local root = model.PrimaryPart
			if not root then
				return
			end

			local targetCharacter, targetRoot = self:FindSummonTarget(ownerPlayer, root.Position, detectRadius)
			if targetCharacter and targetRoot then
				humanoid:MoveTo(targetRoot.Position)

				if (targetRoot.Position - root.Position).Magnitude <= attackRadius and os.clock() - lastAttack >= attackCooldown then
					lastAttack = os.clock()
					local damaged = CombatService:DamageCharacter(ownerPlayer, targetCharacter, attackDamage, abilityName)
					if damaged then
						self:ShowSummonStrikeEffect(targetRoot.Position, definition)
					end
				end
			else
				humanoid:MoveTo(root.Position)
			end

			task.wait(0.3)
		end

		if model.Parent then
			self:ShowSummonVanishEffect(model.PrimaryPart and model.PrimaryPart.Position or model:GetPivot().Position, definition)
			model:Destroy()
		end
	end)
end

function SpellService:FindSummonTarget(ownerPlayer, position, detectRadius)
	local bestCharacter = nil
	local bestRoot = nil
	local bestDistance = detectRadius

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= ownerPlayer
			and player.Character
			and not CombatService:IsFriendlyTarget(ownerPlayer, player.Character)
			and not SafeZoneService:IsPlayerInSafeZone(player)
			and not SafeZoneService:IsPlayerExitProtected(player) then
			local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
			local root = player.Character:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root then
				local distance = (root.Position - position).Magnitude
				if distance < bestDistance then
					bestDistance = distance
					bestCharacter = player.Character
					bestRoot = root
				end
			end
		end
	end

	for _, candidate in ipairs(Workspace:GetDescendants()) do
		if candidate:IsA("Model")
			and (candidate:GetAttribute("IsMob") or candidate:GetAttribute("IsBoss"))
			and not candidate:GetAttribute("IsSummon") then
			local humanoid = candidate:FindFirstChildOfClass("Humanoid")
			local root = candidate:FindFirstChild("HumanoidRootPart")
			if humanoid and humanoid.Health > 0 and root then
				local distance = (root.Position - position).Magnitude
				if distance < bestDistance then
					bestDistance = distance
					bestCharacter = candidate
					bestRoot = root
				end
			end
		end
	end

	return bestCharacter, bestRoot
end

function SpellService:DamageCharactersInRadius(attackerPlayer, casterCharacter, position, radius, damage, abilityName, definition, hitCharacters)
	hitCharacters = hitCharacters or {}
	local hitSomething = false

	for _, part in ipairs(Workspace:GetPartBoundsInRadius(position, radius)) do
		local targetCharacter, targetHumanoid = CombatService:GetHumanoidModelFromPart(part)
		if targetCharacter and targetHumanoid and targetHumanoid.Health > 0 and targetCharacter ~= casterCharacter and not hitCharacters[targetCharacter] then
			hitCharacters[targetCharacter] = true
			local damaged = CombatService:DamageCharacter(attackerPlayer, targetCharacter, damage, abilityName)
			if damaged then
				hitSomething = true
				self:ApplyAbilityEffects(attackerPlayer, targetCharacter, definition)
			end
		end
	end

	return hitSomething
end

function SpellService:CreateProjectile(origin, direction, definition)
	local visual = definition.Visual or {}
	local size = visual.ProjectileSize or Vector3.new(2.2, 2.2, 2.2)
	local projectile = Instance.new("Part")
	projectile.Name = (definition.DisplayName or "Ability") .. " Projectile"
	projectile.Anchored = true
	projectile.CanCollide = false
	projectile.CanQuery = false
	projectile.CanTouch = false
	projectile.CastShadow = false
	projectile.Shape = Enum.PartType.Ball
	projectile.Material = visual.Material or Enum.Material.Neon
	projectile.Color = definition.Color or Color3.fromRGB(255, 255, 255)
	projectile.Size = size
	projectile.CFrame = CFrame.lookAt(origin, origin + direction)
	projectile.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Color = projectile.Color
	light.Range = visual.LightRange or 12
	light.Brightness = visual.LightBrightness or 1.2
	light.Parent = projectile

	Debris:AddItem(projectile, (definition.Range or 100) / (definition.ProjectileSpeed or 90) + 1)
	return projectile
end

function SpellService:ExplodeAt(player, character, abilityName, definition, position)
	local radius = definition.ExplosionRadius or definition.Radius or 12
	self:DamageCharactersInRadius(player, character, position, radius, definition.Damage or 0, abilityName, definition)
	self:ShowExplosionEffect(position, radius, definition)
end

function SpellService:ShowRayEffect(origin, endPosition, definition)
	local distance = (endPosition - origin).Magnitude
	local midpoint = origin:Lerp(endPosition, 0.5)
	local visual = definition.Visual or {}
	local width = visual.Width or 0.7
	local lifetime = visual.Lifetime or 0.14
	local material = visual.Material or Enum.Material.Neon
	local shape = visual.Shape or "Beam"

	local bolt = Instance.new("Part")
	bolt.Name = (definition.DisplayName or "Ability") .. " Ray Effect"
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
		secondary.Name = (definition.DisplayName or "Ability") .. " Secondary Ray"
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
		core.Name = (definition.DisplayName or "Ability") .. " Ray Core"
		core.Anchored = true
		core.CanCollide = false
		core.Material = Enum.Material.Neon
		core.Color = visual.SecondaryColor
		core.Size = Vector3.new(width * 0.35, width * 0.35, math.max(distance, 1))
		core.CFrame = CFrame.lookAt(midpoint, endPosition)
		core.Parent = Workspace
		Debris:AddItem(core, lifetime)
	end

	self:ShowImpactSpark(endPosition, definition)
	Debris:AddItem(bolt, lifetime)
end

function SpellService:ShowExplosionEffect(position, radius, definition)
	local visual = definition.Visual or {}
	local blast = Instance.new("Part")
	blast.Name = (definition.DisplayName or "Ability") .. " Explosion"
	blast.Anchored = true
	blast.CanCollide = false
	blast.Shape = Enum.PartType.Ball
	blast.Material = visual.Material or Enum.Material.Neon
	blast.Color = definition.Color or Color3.fromRGB(255, 255, 255)
	blast.Transparency = visual.ExplosionTransparency or 0.42
	blast.Size = Vector3.new(1, 1, 1)
	blast.CFrame = CFrame.new(position)
	blast.Parent = Workspace

	local light = Instance.new("PointLight")
	light.Color = blast.Color
	light.Range = radius * 1.8
	light.Brightness = visual.LightBrightness or 2
	light.Parent = blast

	TweenService:Create(blast, TweenInfo.new(visual.ExplosionLifetime or 0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(radius * 2, radius * 2, radius * 2),
		Transparency = 1,
	}):Play()

	Debris:AddItem(blast, visual.ExplosionLifetime or 0.36)
end

function SpellService:ShowAreaEffect(origin, radius, definition)
	local visual = definition.Visual or {}
	local ring = Instance.new("Part")
	ring.Name = (definition.DisplayName or "Ability") .. " Area Effect"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Neon
	ring.Color = definition.Color
	ring.Transparency = visual.Transparency or 0.45
	ring.Size = Vector3.new(visual.Height or 0.35, 1, 1)
	ring.CFrame = CFrame.new(origin + Vector3.new(0, 0.15, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace

	TweenService:Create(ring, TweenInfo.new(visual.Lifetime or 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(visual.Height or 0.35, radius * 2, radius * 2),
		Transparency = 1,
	}):Play()

	Debris:AddItem(ring, visual.Lifetime or 0.3)
end

function SpellService:ShowIceNovaStep(origin, radius, step, definition)
	local visual = definition.Visual or {}
	local ring = Instance.new("Part")
	ring.Name = (definition.DisplayName or "Ice Nova") .. " Spreading Ring"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Ice
	ring.Color = definition.Color or Color3.fromRGB(170, 230, 255)
	ring.Transparency = 0.45
	ring.Size = Vector3.new(0.16, radius * 2, radius * 2)
	ring.CFrame = CFrame.new(origin - Vector3.new(0, 2.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace
	Debris:AddItem(ring, 0.35)

	local spikeCount = math.clamp(4 + step, 5, 12)
	for index = 1, spikeCount do
		local angle = (math.pi * 2 / spikeCount) * index + step * 0.35
		local spikePosition = origin + Vector3.new(math.cos(angle) * radius, -2, math.sin(angle) * radius)
		self:ShowIceSpike(spikePosition, 2.5 + (index % 3), visual.SecondaryColor or Color3.fromRGB(225, 250, 255))
	end
end

function SpellService:ShowLineWaveStep(position, direction, step, definition)
	local visual = definition.Visual or {}
	local side = direction:Cross(Vector3.yAxis)
	if side.Magnitude < 0.01 then
		side = Vector3.xAxis
	else
		side = side.Unit
	end

	local color = visual.SecondaryColor or definition.Color or Color3.fromRGB(200, 245, 255)
	self:ShowIceSpike(position, 3.5 + step * 0.25, color)
	self:ShowIceSpike(position + side * 3.5, 2.5 + step * 0.12, color)
	self:ShowIceSpike(position - side * 3.5, 2.5 + step * 0.12, color)
end

function SpellService:ShowIceSpike(position, height, color)
	local spike = Instance.new("Part")
	spike.Name = "Ice Spike"
	spike.Anchored = true
	spike.CanCollide = false
	spike.Material = Enum.Material.Ice
	spike.Color = color
	spike.Transparency = 0.15
	spike.Size = Vector3.new(1.4, 0.2, 1.4)
	spike.CFrame = CFrame.new(position)
	spike.Parent = Workspace

	TweenService:Create(spike, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new(1.4, height, 1.4),
		CFrame = CFrame.new(position + Vector3.new(0, height * 0.5, 0)) * CFrame.Angles(math.rad(math.random(-10, 10)), math.rad(math.random(0, 180)), math.rad(math.random(-10, 10))),
	}):Play()

	task.delay(0.65, function()
		if spike.Parent then
			TweenService:Create(spike, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Transparency = 1,
				Size = Vector3.new(0.5, 0.2, 0.5),
			}):Play()
		end
	end)

	Debris:AddItem(spike, 0.95)
end

function SpellService:ShowTargetWarning(position, radius, definition, delaySeconds)
	local warning = Instance.new("Part")
	warning.Name = (definition.DisplayName or "Ability") .. " Target Warning"
	warning.Anchored = true
	warning.CanCollide = false
	warning.Shape = Enum.PartType.Cylinder
	warning.Material = Enum.Material.Neon
	warning.Color = definition.Color or Color3.fromRGB(255, 255, 255)
	warning.Transparency = 0.65
	warning.Size = Vector3.new(0.12, radius * 2, radius * 2)
	warning.CFrame = CFrame.new(position - Vector3.new(0, 2.4, 0)) * CFrame.Angles(0, 0, math.rad(90))
	warning.Parent = Workspace
	Debris:AddItem(warning, delaySeconds + 0.1)
end

function SpellService:ShowCastBurst(position, definition)
	local visual = definition.Visual or {}
	local burst = Instance.new("Part")
	burst.Name = (definition.DisplayName or "Ability") .. " Cast Burst"
	burst.Anchored = true
	burst.CanCollide = false
	burst.Shape = Enum.PartType.Ball
	burst.Material = visual.Material or Enum.Material.Neon
	burst.Color = definition.Color or Color3.fromRGB(255, 255, 255)
	burst.Transparency = 0.45
	burst.Size = Vector3.new(2, 2, 2)
	burst.CFrame = CFrame.new(position + Vector3.new(0, 2, 0))
	burst.Parent = Workspace

	TweenService:Create(burst, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(7, 7, 7),
		Transparency = 1,
	}):Play()

	Debris:AddItem(burst, 0.22)
end

function SpellService:ShowImpactSpark(position, definition)
	local visual = definition.Visual or {}
	local spark = Instance.new("Part")
	spark.Name = (definition.DisplayName or "Ability") .. " Impact Spark"
	spark.Anchored = true
	spark.CanCollide = false
	spark.Shape = Enum.PartType.Ball
	spark.Material = Enum.Material.Neon
	spark.Color = visual.SecondaryColor or definition.Color or Color3.fromRGB(255, 255, 255)
	spark.Transparency = 0.1
	spark.Size = Vector3.new(1.2, 1.2, 1.2)
	spark.CFrame = CFrame.new(position)
	spark.Parent = Workspace

	TweenService:Create(spark, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(4.2, 4.2, 4.2),
		Transparency = 1,
	}):Play()

	Debris:AddItem(spark, 0.2)
end

function SpellService:ShowSummonEffect(position, definition)
	local visual = definition.Visual or {}
	local radius = visual.SummonRadius or 7
	local ring = Instance.new("Part")
	ring.Name = (definition.DisplayName or "Summon") .. " Summon Ring"
	ring.Anchored = true
	ring.CanCollide = false
	ring.Shape = Enum.PartType.Cylinder
	ring.Material = Enum.Material.Ice
	ring.Color = definition.Color or Color3.fromRGB(180, 235, 255)
	ring.Transparency = 0.35
	ring.Size = Vector3.new(0.16, 1, 1)
	ring.CFrame = CFrame.new(position + Vector3.new(0, 0.1, 0)) * CFrame.Angles(0, 0, math.rad(90))
	ring.Parent = Workspace

	TweenService:Create(ring, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = Vector3.new(0.16, radius * 2, radius * 2),
		Transparency = 0.58,
	}):Play()

	for index = 1, 7 do
		local angle = (math.pi * 2 / 7) * index
		self:ShowIceSpike(position + Vector3.new(math.cos(angle) * radius * 0.55, 0, math.sin(angle) * radius * 0.55), 3 + (index % 2), visual.SecondaryColor or Color3.fromRGB(235, 255, 255))
	end

	Debris:AddItem(ring, 0.8)
end

function SpellService:ShowSummonStrikeEffect(position, definition)
	local visual = definition.Visual or {}
	self:ShowIceSpike(position - Vector3.new(0, 2, 0), 3.2, visual.SecondaryColor or definition.Color or Color3.fromRGB(220, 250, 255))
end

function SpellService:ShowSummonVanishEffect(position, definition)
	local mist = Instance.new("Part")
	mist.Name = (definition.DisplayName or "Summon") .. " Vanish"
	mist.Anchored = true
	mist.CanCollide = false
	mist.Shape = Enum.PartType.Ball
	mist.Material = Enum.Material.ForceField
	mist.Color = definition.Color or Color3.fromRGB(180, 235, 255)
	mist.Transparency = 0.4
	mist.Size = Vector3.new(4, 4, 4)
	mist.CFrame = CFrame.new(position)
	mist.Parent = Workspace

	TweenService:Create(mist, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(10, 10, 10),
		Transparency = 1,
	}):Play()

	Debris:AddItem(mist, 0.35)
end

function SpellService:ShowBuffEffect(character, definition)
	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return
	end

	local visual = definition.Visual or {}
	local aura = Instance.new("Part")
	aura.Name = (definition.DisplayName or "Ability") .. " Buff Effect"
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
		core.Name = (definition.DisplayName or "Ability") .. " Buff Core Effect"
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
	SpellService:DestroyPlayerSummons(player)
end)

return SpellService
