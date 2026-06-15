local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local AbilityDefinitions = require(ReplicatedStorage.Modules.AbilityDefinitions)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local combatFeedback = remotes:WaitForChild("CombatFeedback")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "CombatFeedback"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local hitMarker = Instance.new("TextLabel")
hitMarker.Name = "HitMarker"
hitMarker.AnchorPoint = Vector2.new(0.5, 0.5)
hitMarker.BackgroundTransparency = 1
hitMarker.Position = UDim2.fromScale(0.5, 0.5)
hitMarker.Size = UDim2.fromOffset(44, 44)
hitMarker.Font = Enum.Font.GothamBold
hitMarker.Text = "X"
hitMarker.TextColor3 = Color3.fromRGB(255, 245, 210)
hitMarker.TextSize = 24
hitMarker.TextTransparency = 1
hitMarker.Parent = screenGui

local castFlash = Instance.new("Frame")
castFlash.Name = "CastFlash"
castFlash.AnchorPoint = Vector2.new(0.5, 0.5)
castFlash.BackgroundTransparency = 1
castFlash.BorderSizePixel = 0
castFlash.Position = UDim2.fromScale(0.5, 0.5)
castFlash.Size = UDim2.fromOffset(24, 24)
castFlash.Parent = screenGui

local castFlashCorner = Instance.new("UICorner")
castFlashCorner.CornerRadius = UDim.new(1, 0)
castFlashCorner.Parent = castFlash

local castFlashStroke = Instance.new("UIStroke")
castFlashStroke.Name = "Stroke"
castFlashStroke.Color = Color3.fromRGB(255, 255, 255)
castFlashStroke.Thickness = 2
castFlashStroke.Transparency = 1
castFlashStroke.Parent = castFlash

local rewardLabel = Instance.new("TextLabel")
rewardLabel.Name = "RewardLabel"
rewardLabel.AnchorPoint = Vector2.new(0.5, 1)
rewardLabel.BackgroundTransparency = 1
rewardLabel.Position = UDim2.fromScale(0.5, 0.82)
rewardLabel.Size = UDim2.fromOffset(240, 30)
rewardLabel.Font = Enum.Font.GothamBold
rewardLabel.Text = ""
rewardLabel.TextColor3 = Color3.fromRGB(255, 225, 95)
rewardLabel.TextSize = 20
rewardLabel.TextStrokeColor3 = Color3.fromRGB(35, 25, 10)
rewardLabel.TextStrokeTransparency = 1
rewardLabel.TextTransparency = 1
rewardLabel.Parent = screenGui

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "CombatStatusLabel"
statusLabel.AnchorPoint = Vector2.new(0.5, 0.5)
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.fromScale(0.5, 0.58)
statusLabel.Size = UDim2.fromOffset(320, 28)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = ""
statusLabel.TextColor3 = Color3.fromRGB(180, 225, 255)
statusLabel.TextSize = 18
statusLabel.TextStrokeColor3 = Color3.fromRGB(10, 18, 24)
statusLabel.TextStrokeTransparency = 1
statusLabel.TextTransparency = 1
statusLabel.Parent = screenGui

local bossFrame = Instance.new("Frame")
bossFrame.Name = "BossHealth"
bossFrame.AnchorPoint = Vector2.new(0.5, 0)
bossFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 20)
bossFrame.BackgroundTransparency = 0.08
bossFrame.BorderSizePixel = 0
bossFrame.Position = UDim2.fromScale(0.5, 0.075)
bossFrame.Size = UDim2.fromOffset(430, 52)
bossFrame.Visible = false
bossFrame.Parent = screenGui

local bossFrameCorner = Instance.new("UICorner")
bossFrameCorner.CornerRadius = UDim.new(0, 6)
bossFrameCorner.Parent = bossFrame

local bossFrameStroke = Instance.new("UIStroke")
bossFrameStroke.Color = Color3.fromRGB(255, 90, 65)
bossFrameStroke.Thickness = 1
bossFrameStroke.Transparency = 0.2
bossFrameStroke.Parent = bossFrame

local bossNameLabel = Instance.new("TextLabel")
bossNameLabel.Name = "BossName"
bossNameLabel.BackgroundTransparency = 1
bossNameLabel.Position = UDim2.fromOffset(12, 4)
bossNameLabel.Size = UDim2.new(1, -24, 0, 18)
bossNameLabel.Font = Enum.Font.GothamBold
bossNameLabel.Text = "Boss"
bossNameLabel.TextColor3 = Color3.fromRGB(255, 235, 220)
bossNameLabel.TextSize = 14
bossNameLabel.TextXAlignment = Enum.TextXAlignment.Left
bossNameLabel.Parent = bossFrame

local bossHealthText = Instance.new("TextLabel")
bossHealthText.Name = "HealthText"
bossHealthText.BackgroundTransparency = 1
bossHealthText.Position = UDim2.fromOffset(12, 4)
bossHealthText.Size = UDim2.new(1, -24, 0, 18)
bossHealthText.Font = Enum.Font.Gotham
bossHealthText.Text = ""
bossHealthText.TextColor3 = Color3.fromRGB(230, 230, 230)
bossHealthText.TextSize = 13
bossHealthText.TextXAlignment = Enum.TextXAlignment.Right
bossHealthText.Parent = bossFrame

local bossBarBack = Instance.new("Frame")
bossBarBack.Name = "BarBack"
bossBarBack.BackgroundColor3 = Color3.fromRGB(45, 28, 28)
bossBarBack.BorderSizePixel = 0
bossBarBack.Position = UDim2.fromOffset(12, 28)
bossBarBack.Size = UDim2.new(1, -24, 0, 14)
bossBarBack.Parent = bossFrame

local bossBarBackCorner = Instance.new("UICorner")
bossBarBackCorner.CornerRadius = UDim.new(0, 4)
bossBarBackCorner.Parent = bossBarBack

local bossBarFill = Instance.new("Frame")
bossBarFill.Name = "Fill"
bossBarFill.BackgroundColor3 = Color3.fromRGB(255, 78, 52)
bossBarFill.BorderSizePixel = 0
bossBarFill.Size = UDim2.fromScale(1, 1)
bossBarFill.Parent = bossBarBack

local bossBarFillCorner = Instance.new("UICorner")
bossBarFillCorner.CornerRadius = UDim.new(0, 4)
bossBarFillCorner.Parent = bossBarFill

local bossHideToken = 0

local deathFrame = Instance.new("Frame")
deathFrame.Name = "DeathMessage"
deathFrame.AnchorPoint = Vector2.new(0.5, 0.5)
deathFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
deathFrame.BackgroundTransparency = 0.15
deathFrame.BorderSizePixel = 0
deathFrame.Position = UDim2.fromScale(0.5, 0.38)
deathFrame.Size = UDim2.fromOffset(360, 116)
deathFrame.Visible = false
deathFrame.Parent = screenGui

local deathFrameCorner = Instance.new("UICorner")
deathFrameCorner.CornerRadius = UDim.new(0, 6)
deathFrameCorner.Parent = deathFrame

local deathFrameStroke = Instance.new("UIStroke")
deathFrameStroke.Color = Color3.fromRGB(255, 80, 70)
deathFrameStroke.Thickness = 1
deathFrameStroke.Transparency = 0.25
deathFrameStroke.Parent = deathFrame

local deathTitle = Instance.new("TextLabel")
deathTitle.Name = "Title"
deathTitle.BackgroundTransparency = 1
deathTitle.Position = UDim2.fromOffset(14, 12)
deathTitle.Size = UDim2.new(1, -28, 0, 30)
deathTitle.Font = Enum.Font.GothamBlack
deathTitle.Text = "You were defeated"
deathTitle.TextColor3 = Color3.fromRGB(255, 235, 230)
deathTitle.TextSize = 24
deathTitle.Parent = deathFrame

local deathDetail = Instance.new("TextLabel")
deathDetail.Name = "Detail"
deathDetail.BackgroundTransparency = 1
deathDetail.Position = UDim2.fromOffset(14, 48)
deathDetail.Size = UDim2.new(1, -28, 0, 22)
deathDetail.Font = Enum.Font.Gotham
deathDetail.Text = ""
deathDetail.TextColor3 = Color3.fromRGB(230, 220, 215)
deathDetail.TextSize = 15
deathDetail.Parent = deathFrame

local deathCountdown = Instance.new("TextLabel")
deathCountdown.Name = "Countdown"
deathCountdown.BackgroundTransparency = 1
deathCountdown.Position = UDim2.fromOffset(14, 76)
deathCountdown.Size = UDim2.new(1, -28, 0, 22)
deathCountdown.Font = Enum.Font.GothamBold
deathCountdown.Text = ""
deathCountdown.TextColor3 = Color3.fromRGB(255, 205, 95)
deathCountdown.TextSize = 16
deathCountdown.Parent = deathFrame

local deathToken = 0
local lowHealthWarningReady = true

local function getAdornee(targetCharacter)
	if not targetCharacter then
		return nil
	end

	return targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter.PrimaryPart
end

local function getTargetPosition(targetCharacter)
	local adornee = getAdornee(targetCharacter)
	return adornee and adornee.Position or nil
end

local function playSound(soundId, volume, pitch, parent)
	if not soundId or soundId == "" then
		return
	end

	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.45
	sound.PlaybackSpeed = pitch or 1
	sound.RollOffMaxDistance = 90
	sound.Parent = parent or SoundService
	sound:Play()
	Debris:AddItem(sound, 3)
end

local function getAudioDefinition(sourceName)
	local definition = sourceName and AbilityDefinitions[sourceName]
	return definition and definition.Audio or nil, definition
end

local function showCastFlash(abilityName)
	local _, definition = getAudioDefinition(abilityName)
	local color = definition and definition.Color or Color3.fromRGB(255, 245, 210)

	castFlash.BackgroundColor3 = color
	castFlash.BackgroundTransparency = 0.78
	castFlash.Stroke.Color = color
	castFlash.Stroke.Transparency = 0.05
	castFlash.Size = UDim2.fromOffset(18, 18)

	TweenService:Create(castFlash, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(60, 60),
		BackgroundTransparency = 1,
	}):Play()

	TweenService:Create(castFlash.Stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Transparency = 1,
	}):Play()
end

local function showImpactPulse(targetCharacter, sourceName)
	local adornee = getAdornee(targetCharacter)
	if not adornee then
		return
	end

	local _, definition = getAudioDefinition(sourceName)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ImpactPulse"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 180
	billboard.Size = UDim2.fromOffset(44, 44)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 2.1, 0)
	billboard.Parent = screenGui

	local pulse = Instance.new("Frame")
	pulse.AnchorPoint = Vector2.new(0.5, 0.5)
	pulse.BackgroundColor3 = definition and definition.Color or Color3.fromRGB(255, 245, 210)
	pulse.BackgroundTransparency = 0.45
	pulse.BorderSizePixel = 0
	pulse.Position = UDim2.fromScale(0.5, 0.5)
	pulse.Size = UDim2.fromOffset(12, 12)
	pulse.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = pulse

	TweenService:Create(pulse, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(52, 52),
		BackgroundTransparency = 1,
	}):Play()

	Debris:AddItem(billboard, 0.28)
end

local function showDamageNumber(targetCharacter, amount)
	local adornee = getAdornee(targetCharacter)
	if not adornee then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.Adornee = adornee
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 220
	billboard.Size = UDim2.fromOffset(104, 42)
	billboard.StudsOffsetWorldSpace = Vector3.new(math.random(-2, 2), 4, 0)
	billboard.Parent = screenGui

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = tostring(amount)
	label.TextColor3 = Color3.fromRGB(255, 235, 105)
	label.TextSize = 30
	label.TextStrokeColor3 = Color3.fromRGB(30, 24, 20)
	label.TextStrokeTransparency = 0.2
	label.Parent = billboard

	TweenService:Create(billboard, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		StudsOffsetWorldSpace = billboard.StudsOffsetWorldSpace + Vector3.new(0, 2.4, 0),
	}):Play()

	TweenService:Create(label, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()

	Debris:AddItem(billboard, 0.75)
end

local function playImpactFeedback(targetCharacter, sourceName)
	local audio = getAudioDefinition(sourceName)
	if not audio then
		return
	end

	local targetPosition = getTargetPosition(targetCharacter)
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if targetPosition and root and (targetPosition - root.Position).Magnitude > 120 then
		return
	end

	playSound(audio.ImpactSoundId, audio.ImpactVolume, audio.Pitch)
end

local function playCastFeedback(abilityName)
	local audio = getAudioDefinition(abilityName)
	if audio then
		playSound(audio.CastSoundId, audio.CastVolume, audio.Pitch)
	end

	showCastFlash(abilityName)
end

local function showReward(amount, reason)
	rewardLabel.Text = ("+%d TrashCoins"):format(amount or 0)
	if reason and reason ~= "" then
		rewardLabel.Text = rewardLabel.Text .. "  " .. reason
	end

	rewardLabel.Position = UDim2.fromScale(0.5, 0.82)
	rewardLabel.TextTransparency = 0
	rewardLabel.TextStrokeTransparency = 0.35

	TweenService:Create(rewardLabel, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.78),
	}):Play()

	TweenService:Create(rewardLabel, TweenInfo.new(0.65, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

local function showCombatStatus(message, color)
	statusLabel.Text = message
	statusLabel.TextColor3 = color or Color3.fromRGB(180, 225, 255)
	statusLabel.Position = UDim2.fromScale(0.5, 0.58)
	statusLabel.TextTransparency = 0
	statusLabel.TextStrokeTransparency = 0.35

	TweenService:Create(statusLabel, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.55),
	}):Play()

	TweenService:Create(statusLabel, TweenInfo.new(0.55, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

local function bindLowHealthWarning(character)
	local humanoid = character:WaitForChild("Humanoid", 5)
	if not humanoid then
		return
	end

	lowHealthWarningReady = true
	humanoid.HealthChanged:Connect(function(health)
		if humanoid.MaxHealth <= 0 then
			return
		end

		if health > humanoid.MaxHealth * 0.35 then
			lowHealthWarningReady = true
			return
		end

		if health > 0 and lowHealthWarningReady then
			lowHealthWarningReady = false
			showCombatStatus("Low health - return to base", Color3.fromRGB(255, 120, 85))
		end
	end)
end

local function updateBossHealth(bossName, health, maxHealth, isActive)
	maxHealth = math.max(maxHealth or 0, 0)
	health = math.clamp(health or 0, 0, maxHealth)

	if not isActive or maxHealth <= 0 then
		bossHideToken += 1
		local token = bossHideToken
		task.delay(0.65, function()
			if bossHideToken == token then
				bossFrame.Visible = false
			end
		end)
	else
		bossHideToken += 1
		bossFrame.Visible = true
	end

	local ratio = 0
	if maxHealth > 0 then
		ratio = math.clamp(health / maxHealth, 0, 1)
	end

	bossNameLabel.Text = bossName or "Boss"
	bossHealthText.Text = ("%d / %d"):format(math.floor(health + 0.5), math.floor(maxHealth + 0.5))

	TweenService:Create(bossBarFill, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromScale(ratio, 1),
	}):Play()
end

local function showDeathMessage(killerName, sourceName, duration)
	deathToken += 1
	local token = deathToken
	duration = math.max(duration or 3, 1)

	if killerName and killerName ~= "" then
		if sourceName and sourceName ~= "" then
			deathDetail.Text = ("Defeated by %s with %s"):format(killerName, sourceName)
		else
			deathDetail.Text = ("Defeated by %s"):format(killerName)
		end
	else
		deathDetail.Text = "Defeated by the Trashlands"
	end

	deathFrame.Visible = true
	deathFrame.BackgroundTransparency = 0.15
	deathFrameStroke.Transparency = 0.25
	deathTitle.TextTransparency = 0
	deathDetail.TextTransparency = 0
	deathCountdown.TextTransparency = 0

	task.spawn(function()
		for remaining = math.ceil(duration), 1, -1 do
			if deathToken ~= token then
				return
			end

			deathCountdown.Text = ("Respawning in %d"):format(remaining)
			task.wait(1)
		end

		if deathToken ~= token then
			return
		end

		deathCountdown.Text = "Respawning..."
		TweenService:Create(deathFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			BackgroundTransparency = 1,
		}):Play()
		TweenService:Create(deathFrameStroke, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			Transparency = 1,
		}):Play()
		TweenService:Create(deathTitle, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		}):Play()
		TweenService:Create(deathDetail, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		}):Play()
		TweenService:Create(deathCountdown, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			TextTransparency = 1,
		}):Play()

		task.delay(0.32, function()
			if deathToken == token then
				deathFrame.Visible = false
			end
		end)
	end)
end

local function showHitConfirm()
	hitMarker.TextTransparency = 0
	hitMarker.TextStrokeTransparency = 0.25
	hitMarker.Size = UDim2.fromOffset(34, 34)

	TweenService:Create(hitMarker, TweenInfo.new(0.12, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(48, 48),
	}):Play()

	TweenService:Create(hitMarker, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		TextTransparency = 1,
		TextStrokeTransparency = 1,
	}):Play()
end

combatFeedback.OnClientEvent:Connect(function(feedbackType, targetCharacter, amount, sourceName, extra)
	if feedbackType == "DamageNumber" then
		showDamageNumber(targetCharacter, amount)
		showImpactPulse(targetCharacter, sourceName)
		playImpactFeedback(targetCharacter, sourceName)
	elseif feedbackType == "HitConfirm" then
		showHitConfirm()
	elseif feedbackType == "AbilityCast" then
		playCastFeedback(targetCharacter)
	elseif feedbackType == "Reward" then
		showReward(targetCharacter, amount)
	elseif feedbackType == "DamageBlocked" then
		showCombatStatus("Damage blocked by safe zone", Color3.fromRGB(145, 220, 255))
	elseif feedbackType == "BossHealth" then
		updateBossHealth(targetCharacter, amount, sourceName, extra)
	elseif feedbackType == "Death" then
		showDeathMessage(targetCharacter, amount, sourceName)
	end
end)

if player.Character then
	bindLowHealthWarning(player.Character)
end

player.CharacterAdded:Connect(bindLowHealthWarning)
