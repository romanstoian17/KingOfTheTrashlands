local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "OnboardingGuide"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local objectiveFrame = Instance.new("Frame")
objectiveFrame.Name = "ObjectiveFrame"
objectiveFrame.AnchorPoint = Vector2.new(0.5, 0)
objectiveFrame.BackgroundColor3 = Color3.fromRGB(20, 24, 26)
objectiveFrame.BackgroundTransparency = 0.08
objectiveFrame.BorderSizePixel = 0
objectiveFrame.Position = UDim2.fromScale(0.5, 0.145)
objectiveFrame.Size = UDim2.fromOffset(390, 56)
objectiveFrame.Parent = screenGui

local objectiveCorner = Instance.new("UICorner")
objectiveCorner.CornerRadius = UDim.new(0, 8)
objectiveCorner.Parent = objectiveFrame

local objectiveStroke = Instance.new("UIStroke")
objectiveStroke.Color = Color3.fromRGB(255, 210, 95)
objectiveStroke.Thickness = 1
objectiveStroke.Transparency = 0.15
objectiveStroke.Parent = objectiveFrame

local objectiveTitle = Instance.new("TextLabel")
objectiveTitle.Name = "Title"
objectiveTitle.BackgroundTransparency = 1
objectiveTitle.Position = UDim2.fromOffset(14, 6)
objectiveTitle.Size = UDim2.new(1, -28, 0, 22)
objectiveTitle.Font = Enum.Font.GothamBlack
objectiveTitle.Text = "OBJECTIVE"
objectiveTitle.TextColor3 = Color3.fromRGB(255, 232, 150)
objectiveTitle.TextSize = 14
objectiveTitle.TextXAlignment = Enum.TextXAlignment.Left
objectiveTitle.Parent = objectiveFrame

local objectiveText = Instance.new("TextLabel")
objectiveText.Name = "Text"
objectiveText.BackgroundTransparency = 1
objectiveText.Position = UDim2.fromOffset(14, 28)
objectiveText.Size = UDim2.new(1, -28, 0, 20)
objectiveText.Font = Enum.Font.GothamBold
objectiveText.Text = ""
objectiveText.TextColor3 = Color3.fromRGB(238, 242, 235)
objectiveText.TextSize = 15
objectiveText.TextXAlignment = Enum.TextXAlignment.Left
objectiveText.TextTruncate = Enum.TextTruncate.AtEnd
objectiveText.Parent = objectiveFrame

local helpButton = Instance.new("TextButton")
helpButton.Name = "HelpButton"
helpButton.AnchorPoint = Vector2.new(0, 1)
helpButton.BackgroundColor3 = Color3.fromRGB(32, 38, 42)
helpButton.BorderSizePixel = 0
helpButton.Position = UDim2.new(0, 18, 1, -18)
helpButton.Size = UDim2.fromOffset(88, 34)
helpButton.Font = Enum.Font.GothamBold
helpButton.Text = "HELP"
helpButton.TextColor3 = Color3.fromRGB(238, 242, 235)
helpButton.TextSize = 13
helpButton.Parent = screenGui

local helpCorner = Instance.new("UICorner")
helpCorner.CornerRadius = UDim.new(0, 7)
helpCorner.Parent = helpButton

local helpPanel = Instance.new("Frame")
helpPanel.Name = "HelpPanel"
helpPanel.AnchorPoint = Vector2.new(0, 1)
helpPanel.BackgroundColor3 = Color3.fromRGB(20, 24, 26)
helpPanel.BackgroundTransparency = 0.04
helpPanel.BorderSizePixel = 0
helpPanel.Position = UDim2.new(0, 18, 1, -60)
helpPanel.Size = UDim2.fromOffset(330, 190)
helpPanel.Visible = false
helpPanel.Parent = screenGui

local helpPanelCorner = Instance.new("UICorner")
helpPanelCorner.CornerRadius = UDim.new(0, 8)
helpPanelCorner.Parent = helpPanel

local helpText = Instance.new("TextLabel")
helpText.BackgroundTransparency = 1
helpText.Position = UDim2.fromOffset(14, 12)
helpText.Size = UDim2.new(1, -28, 1, -24)
helpText.Font = Enum.Font.GothamMedium
helpText.Text = "Choose a class, then follow yellow paths to the arena.\nPress 1-0 or tap a slot to select an ability.\nClick or tap the world to cast.\nBases are safe zones. Subway pads lead to mobs.\nReturn to base when health is low."
helpText.TextColor3 = Color3.fromRGB(232, 238, 235)
helpText.TextSize = 14
helpText.TextWrapped = true
helpText.TextXAlignment = Enum.TextXAlignment.Left
helpText.TextYAlignment = Enum.TextYAlignment.Top
helpText.Parent = helpPanel

local function isClassSelected()
	return player:GetAttribute("CombatClassSelected") == true or player:GetAttribute("MageTypeSelected") == true
end

local function getRoot()
	local character = player.Character
	return character and character:FindFirstChild("HumanoidRootPart")
end

local function distanceTo(position)
	local root = getRoot()
	if not root then
		return nil
	end

	return (root.Position - position).Magnitude
end

local function nearestSubwayDistance()
	local distanceA = distanceTo(Vector3.new(-64, 1, 64))
	local distanceB = distanceTo(Vector3.new(64, 1, -64))
	if not distanceA then
		return nil
	end

	return math.min(distanceA, distanceB)
end

local function setObjective(text, color)
	if objectiveText.Text == text then
		return
	end

	objectiveText.Text = text
	objectiveStroke.Color = color or Color3.fromRGB(255, 210, 95)
	TweenService:Create(objectiveFrame, TweenInfo.new(0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.fromOffset(410, 58),
	}):Play()
	task.delay(0.16, function()
		if objectiveFrame.Parent then
			TweenService:Create(objectiveFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.fromOffset(390, 56),
			}):Play()
		end
	end)
end

local function updateObjective()
	local root = getRoot()
	if not root then
		setObjective("Loading your fighter...", Color3.fromRGB(180, 210, 255))
		return
	end

	if not isClassSelected() then
		setObjective("Choose a class to start playing.", Color3.fromRGB(255, 210, 95))
		return
	end

	if root.Position.Y < -20 then
		setObjective("Defeat subway mobs or use a green exit pad.", Color3.fromRGB(120, 255, 165))
		return
	end

	local arenaDistance = distanceTo(Vector3.zero)
	if player:GetAttribute("InSafeZone") == true then
		setObjective("Follow the yellow path to the arena.", Color3.fromRGB(255, 210, 95))
	elseif arenaDistance and arenaDistance > 120 then
		setObjective(("Go to the center arena. %d studs"):format(arenaDistance), Color3.fromRGB(255, 210, 95))
	else
		local subwayDistance = nearestSubwayDistance()
		if subwayDistance and subwayDistance < 90 then
			setObjective("Fight players here, or enter a blue subway pad.", Color3.fromRGB(255, 120, 95))
		else
			setObjective("Fight players, watch for the boss, or find subway.", Color3.fromRGB(255, 120, 95))
		end
	end
end

helpButton.Activated:Connect(function()
	helpPanel.Visible = not helpPanel.Visible
end)

RunService.RenderStepped:Connect(updateObjective)
updateObjective()
