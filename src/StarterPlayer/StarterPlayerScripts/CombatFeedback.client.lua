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

combatFeedback.OnClientEvent:Connect(function(feedbackType, targetCharacter, amount, sourceName)
	if feedbackType == "DamageNumber" then
		showDamageNumber(targetCharacter, amount)
		showImpactPulse(targetCharacter, sourceName)
		playImpactFeedback(targetCharacter, sourceName)
	elseif feedbackType == "HitConfirm" then
		showHitConfirm()
	elseif feedbackType == "AbilityCast" then
		playCastFeedback(targetCharacter)
	end
end)
