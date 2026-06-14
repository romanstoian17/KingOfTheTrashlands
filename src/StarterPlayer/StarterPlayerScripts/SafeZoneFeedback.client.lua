local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")
local safeZoneStatus = remotes:WaitForChild("SafeZoneStatus")

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "SafeZoneFeedback"
screenGui.ResetOnSpawn = false
screenGui.IgnoreGuiInset = true
screenGui.Parent = player:WaitForChild("PlayerGui")

local statusFrame = Instance.new("Frame")
statusFrame.Name = "StatusFrame"
statusFrame.AnchorPoint = Vector2.new(0.5, 0)
statusFrame.Position = UDim2.fromScale(0.5, 0.04)
statusFrame.Size = UDim2.fromOffset(220, 42)
statusFrame.BackgroundColor3 = Color3.fromRGB(30, 36, 32)
statusFrame.BackgroundTransparency = 0.08
statusFrame.BorderSizePixel = 0
statusFrame.Parent = screenGui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 8)
corner.Parent = statusFrame

local stroke = Instance.new("UIStroke")
stroke.Thickness = 2
stroke.Color = Color3.fromRGB(95, 255, 135)
stroke.Parent = statusFrame

local statusLabel = Instance.new("TextLabel")
statusLabel.Name = "StatusLabel"
statusLabel.BackgroundTransparency = 1
statusLabel.Size = UDim2.fromScale(1, 1)
statusLabel.Font = Enum.Font.GothamBold
statusLabel.Text = "SAFE ZONE"
statusLabel.TextColor3 = Color3.fromRGB(230, 255, 235)
statusLabel.TextSize = 18
statusLabel.Parent = statusFrame

local subLabel = Instance.new("TextLabel")
subLabel.Name = "SubLabel"
subLabel.AnchorPoint = Vector2.new(0.5, 0)
subLabel.Position = UDim2.fromScale(0.5, 1)
subLabel.Size = UDim2.fromOffset(220, 18)
subLabel.BackgroundTransparency = 1
subLabel.Font = Enum.Font.GothamMedium
subLabel.Text = ""
subLabel.TextColor3 = Color3.fromRGB(205, 216, 208)
subLabel.TextSize = 12
subLabel.Parent = statusFrame

local function tweenStatus(frameColor, strokeColor)
	TweenService:Create(statusFrame, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		BackgroundColor3 = frameColor,
	}):Play()

	TweenService:Create(stroke, TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Color = strokeColor,
	}):Play()
end

local function setStatus(inSafeZone, zoneName)
	if inSafeZone then
		statusLabel.Text = "SAFE ZONE"
		statusLabel.TextColor3 = Color3.fromRGB(230, 255, 235)
		subLabel.Text = zoneName or "Damage disabled"
		tweenStatus(Color3.fromRGB(30, 36, 32), Color3.fromRGB(95, 255, 135))
	else
		statusLabel.Text = "PVP ENABLED"
		statusLabel.TextColor3 = Color3.fromRGB(255, 235, 230)
		subLabel.Text = "Damage enabled"
		tweenStatus(Color3.fromRGB(42, 30, 30), Color3.fromRGB(255, 92, 72))
	end
end

safeZoneStatus.OnClientEvent:Connect(setStatus)

statusLabel.Text = "CHECKING ZONE"
statusLabel.TextColor3 = Color3.fromRGB(235, 240, 245)
subLabel.Text = ""
tweenStatus(Color3.fromRGB(34, 36, 40), Color3.fromRGB(150, 160, 175))
