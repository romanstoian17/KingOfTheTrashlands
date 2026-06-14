local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local AbilityDefinitions = require(ReplicatedStorage.Modules.AbilityDefinitions)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local castAbility = remotes:WaitForChild("CastAbility", 5) or remotes:WaitForChild("CastSpell")
local combatFeedback = remotes:WaitForChild("CombatFeedback")

pcall(function()
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, false)
end)

local keyBySlot = {
	Enum.KeyCode.One,
	Enum.KeyCode.Two,
	Enum.KeyCode.Three,
	Enum.KeyCode.Four,
	Enum.KeyCode.Five,
	Enum.KeyCode.Six,
	Enum.KeyCode.Seven,
	Enum.KeyCode.Eight,
	Enum.KeyCode.Nine,
	Enum.KeyCode.Zero,
}

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbilityHotbar"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local hotbar = Instance.new("Frame")
hotbar.Name = "Hotbar"
hotbar.AnchorPoint = Vector2.new(0.5, 1)
hotbar.Position = UDim2.fromScale(0.5, 0.985)
hotbar.Size = UDim2.fromOffset(390, 74)
hotbar.BackgroundTransparency = 1
hotbar.Parent = screenGui

local layout = Instance.new("UIListLayout")
layout.FillDirection = Enum.FillDirection.Horizontal
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.VerticalAlignment = Enum.VerticalAlignment.Center
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = hotbar

local slots = {}
local abilityToSlot = {}
local selectedSlotIndex = nil
local selectedAbilityName = nil
local selectSlot

local function getAimScreenPosition(camera)
	if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		return camera.ViewportSize * 0.5
	end

	if UserInputService.GamepadEnabled and not UserInputService.MouseEnabled then
		return camera.ViewportSize * 0.5
	end

	return UserInputService:GetMouseLocation()
end

local function getAimPosition()
	local camera = Workspace.CurrentCamera
	if not camera then
		return nil
	end

	local screenPosition = getAimScreenPosition(camera)
	local ray = camera:ViewportPointToRay(screenPosition.X, screenPosition.Y)
	local params = RaycastParams.new()
	params.FilterType = Enum.RaycastFilterType.Exclude

	local character = player.Character
	if character then
		params.FilterDescendantsInstances = { character }
	end

	local result = Workspace:Raycast(ray.Origin, ray.Direction * 1000, params)
	if result then
		return result.Position
	end

	return ray.Origin + ray.Direction * 1000
end

local function getInputScreenPosition(input)
	if input.UserInputType == Enum.UserInputType.Touch then
		return Vector2.new(input.Position.X, input.Position.Y)
	end

	return UserInputService:GetMouseLocation()
end

local function isPointInsideHotbar(point)
	local position = hotbar.AbsolutePosition
	local size = hotbar.AbsoluteSize

	return point.X >= position.X
		and point.X <= position.X + size.X
		and point.Y >= position.Y
		and point.Y <= position.Y + size.Y
end

local function getSlotIndex(slotValue)
	return tonumber(slotValue.Name:match("%d+")) or 1
end

local function getAbilityIcon(abilityDefinition)
	local tags = abilityDefinition and abilityDefinition.Tags or {}
	for _, tag in ipairs(tags) do
		if tag == "Fire" then
			return "F"
		elseif tag == "Ice" then
			return "I"
		elseif tag == "Lightning" then
			return "L"
		end
	end

	return "A"
end

local function createSlot(index)
	local button = Instance.new("TextButton")
	button.Name = "Slot" .. index
	button.LayoutOrder = index
	button.Size = UDim2.fromOffset(70, 70)
	button.BackgroundColor3 = Color3.fromRGB(28, 31, 34)
	button.BorderSizePixel = 0
	button.AutoButtonColor = true
	button.Text = ""
	button.Visible = false
	button.Parent = hotbar

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Name = "Stroke"
	stroke.Color = Color3.fromRGB(105, 115, 120)
	stroke.Thickness = 1
	stroke.Parent = button

	local selectedMarker = Instance.new("Frame")
	selectedMarker.Name = "SelectedMarker"
	selectedMarker.AnchorPoint = Vector2.new(0.5, 0)
	selectedMarker.Position = UDim2.fromScale(0.5, 0)
	selectedMarker.Size = UDim2.new(1, -18, 0, 4)
	selectedMarker.BackgroundColor3 = Color3.fromRGB(245, 245, 235)
	selectedMarker.BorderSizePixel = 0
	selectedMarker.Visible = false
	selectedMarker.Parent = button

	local selectedMarkerCorner = Instance.new("UICorner")
	selectedMarkerCorner.CornerRadius = UDim.new(1, 0)
	selectedMarkerCorner.Parent = selectedMarker

	local keyLabel = Instance.new("TextLabel")
	keyLabel.Name = "Key"
	keyLabel.BackgroundColor3 = Color3.fromRGB(12, 14, 16)
	keyLabel.BackgroundTransparency = 0.05
	keyLabel.Position = UDim2.fromOffset(5, 5)
	keyLabel.Size = UDim2.fromOffset(18, 18)
	keyLabel.Font = Enum.Font.GothamBold
	keyLabel.Text = index == 10 and "0" or tostring(index)
	keyLabel.TextColor3 = Color3.fromRGB(230, 235, 235)
	keyLabel.TextSize = 11
	keyLabel.Parent = button

	local keyCorner = Instance.new("UICorner")
	keyCorner.CornerRadius = UDim.new(0, 4)
	keyCorner.Parent = keyLabel

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Name = "Icon"
	iconLabel.BackgroundTransparency = 1
	iconLabel.Position = UDim2.fromOffset(8, 16)
	iconLabel.Size = UDim2.new(1, -16, 0, 30)
	iconLabel.Font = Enum.Font.GothamBlack
	iconLabel.Text = ""
	iconLabel.TextColor3 = Color3.fromRGB(245, 245, 235)
	iconLabel.TextSize = 24
	iconLabel.Parent = button

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(4, 47)
	nameLabel.Size = UDim2.new(1, -8, 0, 16)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = ""
	nameLabel.TextColor3 = Color3.fromRGB(235, 238, 238)
	nameLabel.TextScaled = true
	nameLabel.Parent = button

	local cooldown = Instance.new("Frame")
	cooldown.Name = "Cooldown"
	cooldown.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	cooldown.BackgroundTransparency = 0.35
	cooldown.BorderSizePixel = 0
	cooldown.Size = UDim2.fromScale(1, 0)
	cooldown.Position = UDim2.fromScale(0, 1)
	cooldown.AnchorPoint = Vector2.new(0, 1)
	cooldown.Visible = false
	cooldown.Parent = button

	local cooldownCorner = Instance.new("UICorner")
	cooldownCorner.CornerRadius = UDim.new(0, 8)
	cooldownCorner.Parent = cooldown

	button.Activated:Connect(function()
		if selectSlot then
			selectSlot(index)
		end
	end)

	slots[index] = button
	return button
end

for index = 1, 10 do
	createSlot(index)
end

local function clearHotbar()
	table.clear(abilityToSlot)
	selectedSlotIndex = nil
	selectedAbilityName = nil

	for _, slot in ipairs(slots) do
		local nameLabel = slot:FindFirstChild("Name")
		slot:SetAttribute("AbilityName", nil)
		slot.Visible = false
		slot.Icon.Text = ""
		if nameLabel then
			nameLabel.Text = ""
		end
		slot.Cooldown.Visible = false
		slot.Cooldown.Size = UDim2.fromScale(1, 0)
		slot.Stroke.Color = Color3.fromRGB(105, 115, 120)
		slot.Stroke.Thickness = 1
		slot.BackgroundColor3 = Color3.fromRGB(28, 31, 34)
		slot.SelectedMarker.Visible = false
	end
end

local function refreshSelectionVisuals()
	for index, slot in ipairs(slots) do
		local selected = slot.Visible and index == selectedSlotIndex
		slot.BackgroundColor3 = selected and Color3.fromRGB(42, 48, 52) or Color3.fromRGB(28, 31, 34)
		slot.Stroke.Thickness = selected and 3 or 1
		slot.SelectedMarker.Visible = selected
	end
end

selectSlot = function(index)
	local slot = slots[index]
	if not slot then
		return
	end

	local abilityName = slot:GetAttribute("AbilityName")
	if not abilityName then
		return
	end

	selectedSlotIndex = index
	selectedAbilityName = abilityName
	refreshSelectionVisuals()
end

local function setSlot(index, abilityName)
	local slot = slots[index]
	if not slot then
		return
	end

	local definition = AbilityDefinitions[abilityName]
	if not definition then
		return
	end

	local color = definition.Color or Color3.fromRGB(235, 238, 238)
	local nameLabel = slot:FindFirstChild("Name")
	slot:SetAttribute("AbilityName", abilityName)
	slot.Visible = true
	slot.Icon.Text = getAbilityIcon(definition)
	slot.Icon.TextColor3 = color
	if nameLabel then
		nameLabel.Text = definition.DisplayName or abilityName
	end
	slot.Stroke.Color = color
	abilityToSlot[abilityName] = slot
end

local function refreshHotbar()
	clearHotbar()

	local abilityList = player:FindFirstChild("AbilityList")
	if not abilityList then
		return
	end

	local values = abilityList:GetChildren()
	table.sort(values, function(left, right)
		return getSlotIndex(left) < getSlotIndex(right)
	end)

	for _, abilityValue in ipairs(values) do
		if abilityValue:IsA("StringValue") then
			setSlot(getSlotIndex(abilityValue), abilityValue.Value)
		end
	end

	refreshSelectionVisuals()
end

local function bindAbilityList(abilityList)
	refreshHotbar()
	abilityList.ChildAdded:Connect(refreshHotbar)
	abilityList.ChildRemoved:Connect(refreshHotbar)

	for _, child in ipairs(abilityList:GetChildren()) do
		if child:IsA("StringValue") then
			child:GetPropertyChangedSignal("Value"):Connect(refreshHotbar)
		end
	end

	abilityList.ChildAdded:Connect(function(child)
		if child:IsA("StringValue") then
			child:GetPropertyChangedSignal("Value"):Connect(refreshHotbar)
		end
	end)
end

local function startCooldown(abilityName, duration)
	local slot = abilityToSlot[abilityName]
	if not slot then
		return
	end

	local cooldown = slot.Cooldown
	local token = os.clock()
	slot:SetAttribute("CooldownToken", token)
	cooldown.Visible = true
	cooldown.Size = UDim2.fromScale(1, 1)

	TweenService:Create(cooldown, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		Size = UDim2.fromScale(1, 0),
	}):Play()

	task.delay(duration, function()
		if slot.Parent and slot:GetAttribute("CooldownToken") == token then
			cooldown.Visible = false
		end
	end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then
		return
	end

	for index, keyCode in ipairs(keyBySlot) do
		if input.KeyCode == keyCode then
			selectSlot(index)
			return
		end
	end

	if input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
		or input.KeyCode == Enum.KeyCode.ButtonR2 then
		if input.UserInputType ~= Enum.UserInputType.Gamepad1 and isPointInsideHotbar(getInputScreenPosition(input)) then
			return
		end

		if selectedAbilityName then
			castAbility:FireServer(selectedAbilityName, getAimPosition())
		end
	end
end)

combatFeedback.OnClientEvent:Connect(function(feedbackType, abilityName, duration)
	if feedbackType == "SpellCooldown" then
		startCooldown(abilityName, duration)
	end
end)

local existingAbilityList = player:FindFirstChild("AbilityList")
if existingAbilityList then
	bindAbilityList(existingAbilityList)
end

player.ChildAdded:Connect(function(child)
	if child.Name == "AbilityList" then
		bindAbilityList(child)
	end
end)

refreshHotbar()
