local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local selectClass = remotes:WaitForChild("SelectClass", 5) or remotes:WaitForChild("SelectMage")
local classSelectionStatus = remotes:WaitForChild("ClassSelectionStatus", 5) or remotes:WaitForChild("MageSelectionStatus")

local choices = {
	{
		ClassName = "Fire Caster",
		Title = "Fire Caster",
		Icon = "🔥",
		Color = Color3.fromRGB(255, 95, 42),
	},
	{
		ClassName = "Ice Mage",
		Title = "Ice Mage",
		Icon = "❄",
		Color = Color3.fromRGB(135, 225, 255),
	},
	{
		ClassName = "Lightning Mage",
		Title = "Lightning Mage",
		Icon = "⚡",
		Color = Color3.fromRGB(255, 245, 95),
	},
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "ClassSelection"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local overlay = Instance.new("Frame")
overlay.Name = "Overlay"
overlay.BackgroundColor3 = Color3.fromRGB(12, 13, 15)
overlay.BackgroundTransparency = 0.18
overlay.Size = UDim2.fromScale(1, 1)
overlay.Visible = false
overlay.Parent = screenGui

local panel = Instance.new("Frame")
panel.Name = "Panel"
panel.AnchorPoint = Vector2.new(0.5, 0.5)
panel.Position = UDim2.fromScale(0.5, 0.5)
panel.Size = UDim2.fromOffset(600, 285)
panel.BackgroundColor3 = Color3.fromRGB(26, 28, 31)
panel.BorderSizePixel = 0
panel.Parent = overlay

local panelCorner = Instance.new("UICorner")
panelCorner.CornerRadius = UDim.new(0, 8)
panelCorner.Parent = panel

local panelScale = Instance.new("UIScale")
panelScale.Parent = panel

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(24, 18)
title.Size = UDim2.new(1, -48, 0, 36)
title.Font = Enum.Font.GothamBlack
title.Text = "CHOOSE YOUR CLASS"
title.TextColor3 = Color3.fromRGB(242, 242, 235)
title.TextSize = 25
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = panel

local status = Instance.new("TextLabel")
status.BackgroundTransparency = 1
status.Position = UDim2.fromOffset(24, 55)
status.Size = UDim2.new(1, -48, 0, 22)
status.Font = Enum.Font.GothamMedium
status.Text = "Select one class to start."
status.TextColor3 = Color3.fromRGB(190, 198, 200)
status.TextSize = 14
status.TextXAlignment = Enum.TextXAlignment.Left
status.Parent = panel

local closeButton = Instance.new("TextButton")
closeButton.Name = "CloseButton"
closeButton.AnchorPoint = Vector2.new(1, 0)
closeButton.Position = UDim2.new(1, -18, 0, 18)
closeButton.Size = UDim2.fromOffset(30, 30)
closeButton.BackgroundColor3 = Color3.fromRGB(42, 45, 49)
closeButton.BorderSizePixel = 0
closeButton.Font = Enum.Font.GothamBold
closeButton.Text = "X"
closeButton.TextColor3 = Color3.fromRGB(235, 238, 240)
closeButton.TextSize = 14
closeButton.Visible = false
closeButton.Parent = panel

local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeButton

local cards = Instance.new("Frame")
cards.BackgroundTransparency = 1
cards.Position = UDim2.fromOffset(24, 92)
cards.Size = UDim2.new(1, -48, 0, 155)
cards.Parent = panel

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Top
layout.Padding = UDim.new(0, 14)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = cards

local changeButton = Instance.new("TextButton")
changeButton.Name = "ChangeClassButton"
changeButton.AnchorPoint = Vector2.new(1, 0)
changeButton.Position = UDim2.new(1, -18, 0, 118)
changeButton.Size = UDim2.fromOffset(132, 34)
changeButton.BackgroundColor3 = Color3.fromRGB(34, 38, 42)
changeButton.BorderSizePixel = 0
changeButton.Font = Enum.Font.GothamBold
changeButton.Text = "CHANGE CLASS"
changeButton.TextColor3 = Color3.fromRGB(235, 240, 240)
changeButton.TextSize = 12
changeButton.Visible = false
changeButton.Parent = screenGui

local changeCorner = Instance.new("UICorner")
changeCorner.CornerRadius = UDim.new(0, 7)
changeCorner.Parent = changeButton

local changeStroke = Instance.new("UIStroke")
changeStroke.Color = Color3.fromRGB(120, 135, 145)
changeStroke.Thickness = 1
changeStroke.Parent = changeButton

local function isClassSelected()
	return player:GetAttribute("CombatClassSelected") == true or player:GetAttribute("MageTypeSelected") == true
end

local function setOverlayVisible(visible)
	overlay.Visible = visible
	changeButton.Visible = not visible and isClassSelected()
	closeButton.Visible = visible and isClassSelected()
	if visible then
		panel.Size = UDim2.fromOffset(570, 265)
		TweenService:Create(panel, TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.fromOffset(600, 285),
		}):Play()
	end
end

local function refreshChangeButton()
	local inSafeZone = player:GetAttribute("InSafeZone") == true
	changeButton.Visible = isClassSelected() and not overlay.Visible
	changeButton.TextTransparency = inSafeZone and 0 or 0.35
	changeStroke.Transparency = inSafeZone and 0 or 0.55
end

local function showSelectionIfNeeded()
	if not isClassSelected() then
		setOverlayVisible(true)
	end
	refreshChangeButton()
end

local function refreshScale()
	local camera = Workspace.CurrentCamera
	local viewport = camera and camera.ViewportSize or Vector2.new(1280, 720)
	panelScale.Scale = math.clamp(viewport.X / 720, 0.58, 1)
end

for index, choice in ipairs(choices) do
	local card = Instance.new("TextButton")
	card.Name = choice.ClassName
	card.LayoutOrder = index
	card.Size = UDim2.fromOffset(172, 148)
	card.BackgroundColor3 = Color3.fromRGB(35, 38, 41)
	card.BorderSizePixel = 0
	card.AutoButtonColor = true
	card.Text = ""
	card.Parent = cards

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = choice.Color
	stroke.Thickness = 2
	stroke.Parent = card

	local classBar = Instance.new("Frame")
	classBar.BackgroundColor3 = choice.Color
	classBar.BorderSizePixel = 0
	classBar.Position = UDim2.fromOffset(14, 14)
	classBar.Size = UDim2.new(1, -28, 0, 6)
	classBar.Parent = card

	local barCorner = Instance.new("UICorner")
	barCorner.CornerRadius = UDim.new(0, 3)
	barCorner.Parent = classBar

	local name = Instance.new("TextLabel")
	name.BackgroundTransparency = 1
	name.Position = UDim2.fromOffset(14, 105)
	name.Size = UDim2.new(1, -28, 0, 28)
	name.Font = Enum.Font.GothamBlack
	name.Text = choice.Title
	name.TextColor3 = Color3.fromRGB(245, 245, 240)
	name.TextSize = 17
	name.TextXAlignment = Enum.TextXAlignment.Center
	name.Parent = card

	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.fromOffset(14, 28)
	icon.Size = UDim2.new(1, -28, 0, 72)
	icon.Font = Enum.Font.GothamBlack
	icon.Text = choice.Icon
	icon.TextColor3 = choice.Color
	icon.TextSize = 52
	icon.TextXAlignment = Enum.TextXAlignment.Center
	icon.TextYAlignment = Enum.TextYAlignment.Center
	icon.Parent = card

	card.Activated:Connect(function()
		status.Text = "Selecting " .. choice.Title .. "..."
		status.TextColor3 = Color3.fromRGB(220, 225, 225)
		selectClass:FireServer(choice.ClassName)
	end)
end

changeButton.Activated:Connect(function()
	if player:GetAttribute("InSafeZone") == true then
		status.Text = "Select one class."
		status.TextColor3 = Color3.fromRGB(190, 198, 200)
	else
		status.Text = "Change class inside a base safe zone."
		status.TextColor3 = Color3.fromRGB(255, 150, 120)
	end
	setOverlayVisible(true)
end)

closeButton.Activated:Connect(function()
	if isClassSelected() then
		setOverlayVisible(false)
		refreshChangeButton()
	end
end)

classSelectionStatus.OnClientEvent:Connect(function(success, message)
	status.Text = message or ""
	status.TextColor3 = success and Color3.fromRGB(125, 255, 155) or Color3.fromRGB(255, 150, 120)

	if success then
		task.delay(0.45, function()
			setOverlayVisible(false)
			refreshChangeButton()
		end)
	end
end)

player:GetAttributeChangedSignal("CombatClassSelected"):Connect(function()
	showSelectionIfNeeded()
end)

player:GetAttributeChangedSignal("MageTypeSelected"):Connect(function()
	showSelectionIfNeeded()
end)

player:GetAttributeChangedSignal("InSafeZone"):Connect(refreshChangeButton)

if Workspace.CurrentCamera then
	Workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(refreshScale)
end

if not isClassSelected() then
	setOverlayVisible(true)
end
refreshScale()
refreshChangeButton()

task.delay(1, showSelectionIfNeeded)
task.delay(4, showSelectionIfNeeded)
