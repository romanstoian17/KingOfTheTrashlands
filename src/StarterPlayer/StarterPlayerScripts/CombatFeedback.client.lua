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
	billboard.Size = UDim2.fromOffset(32, 32)
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
		Size = UDim2.fromOffset(38, 38),
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
	billboard.Size = UDim2.fromOffset(80, 34)
	billboard.StudsOffsetWorldSpace = Vector3.new(math.random(-2, 2), 4, 0)
	billboard.Parent = screenGui

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Font = Enum.Font.GothamBlack
	label.Text = tostring(amount)
	label.TextColor3 = Color3.fromRGB(255, 235, 105)
	label.TextSize = 24
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
	elseif feedbackType == "BossHealth" then
		updateBossHealth(targetCharacter, amount, sourceName, extra)
	end
end)
