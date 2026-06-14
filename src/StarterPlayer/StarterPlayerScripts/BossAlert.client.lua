local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local bossAlert = remotes:WaitForChild("BossAlert")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "BossAlert"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "AlertFrame"
frame.AnchorPoint = Vector2.new(0.5, 0)
frame.Position = UDim2.fromScale(0.5, -0.18)
frame.Size = UDim2.fromOffset(430, 76)
frame.BackgroundColor3 = Color3.fromRGB(44, 28, 24)
frame.BackgroundTransparency = 0.04
frame.BorderSizePixel = 0
frame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = frame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(255, 88, 52)
stroke.Parent = frame

local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "Title"
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(16, 10)
titleLabel.Size = UDim2.new(1, -32, 0, 30)
titleLabel.Font = Enum.Font.GothamBlack
titleLabel.Text = "TRASH TITAN INCOMING"
titleLabel.TextColor3 = Color3.fromRGB(255, 235, 210)
titleLabel.TextSize = 21
titleLabel.TextXAlignment = Enum.TextXAlignment.Center
titleLabel.Parent = frame

local detailLabel = Instance.new("TextLabel")
detailLabel.Name = "Detail"
detailLabel.BackgroundTransparency = 1
detailLabel.Position = UDim2.fromOffset(16, 42)
detailLabel.Size = UDim2.new(1, -32, 0, 22)
detailLabel.Font = Enum.Font.GothamMedium
detailLabel.Text = "Center Arena"
detailLabel.TextColor3 = Color3.fromRGB(235, 220, 210)
detailLabel.TextSize = 15
detailLabel.TextXAlignment = Enum.TextXAlignment.Center
detailLabel.Parent = frame

local activeToken = 0

local function setColors(alertType)
	if alertType == "Defeated" then
		frame.BackgroundColor3 = Color3.fromRGB(28, 42, 32)
		stroke.Color = Color3.fromRGB(94, 230, 118)
	elseif alertType == "Spawned" then
		frame.BackgroundColor3 = Color3.fromRGB(48, 24, 22)
		stroke.Color = Color3.fromRGB(255, 64, 48)
	else
		frame.BackgroundColor3 = Color3.fromRGB(44, 28, 24)
		stroke.Color = Color3.fromRGB(255, 160, 64)
	end
end

local function showAlert(alertType, title, locationName, seconds)
	activeToken += 1
	local token = activeToken

	setColors(alertType)
	titleLabel.Text = string.upper(title or "BOSS ALERT")

	if alertType == "Warning" then
		detailLabel.Text = string.format("%s in %ds", locationName or "Center Arena", seconds or 0)
	elseif alertType == "Spawned" then
		detailLabel.Text = (locationName or "Center Arena") .. " - fight now"
	else
		detailLabel.Text = locationName or "Center Arena"
	end

	TweenService:Create(frame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0.5, 0.13),
	}):Play()

	local visibleSeconds = 4
	if alertType == "Warning" then
		visibleSeconds = math.clamp(seconds or 4, 4, 8)
	elseif alertType == "Spawned" then
		visibleSeconds = 5
	end

	task.delay(visibleSeconds, function()
		if activeToken == token then
			TweenService:Create(frame, TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Position = UDim2.fromScale(0.5, -0.18),
			}):Play()
		end
	end)
end

bossAlert.OnClientEvent:Connect(showAlert)
