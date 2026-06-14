local Debris = game:GetService("Debris")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

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

local function getAdornee(targetCharacter)
	if not targetCharacter then
		return nil
	end

	return targetCharacter:FindFirstChild("Head") or targetCharacter:FindFirstChild("HumanoidRootPart") or targetCharacter.PrimaryPart
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

combatFeedback.OnClientEvent:Connect(function(feedbackType, targetCharacter, amount)
	if feedbackType == "DamageNumber" then
		showDamageNumber(targetCharacter, amount)
	elseif feedbackType == "HitConfirm" then
		showHitConfirm()
	end
end)
