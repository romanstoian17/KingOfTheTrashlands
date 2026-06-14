local NPCFactory = {}

local function makePart(name, size, color, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Size = size
	part.Color = color
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	return part
end

local function addHealthBar(model, head, humanoid)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HealthBar"
	billboard.Adornee = head
	billboard.AlwaysOnTop = true
	billboard.LightInfluence = 0
	billboard.MaxDistance = 180
	billboard.Size = UDim2.fromOffset(110, 18)
	billboard.StudsOffsetWorldSpace = Vector3.new(0, 3.5, 0)
	billboard.Parent = model

	local background = Instance.new("Frame")
	background.Name = "Background"
	background.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	background.BorderSizePixel = 0
	background.Size = UDim2.fromScale(1, 1)
	background.Parent = billboard

	local backgroundCorner = Instance.new("UICorner")
	backgroundCorner.CornerRadius = UDim.new(0, 4)
	backgroundCorner.Parent = background

	local fill = Instance.new("Frame")
	fill.Name = "Fill"
	fill.BackgroundColor3 = Color3.fromRGB(220, 55, 45)
	fill.BorderSizePixel = 0
	fill.Size = UDim2.fromScale(1, 1)
	fill.Parent = background

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(0, 4)
	fillCorner.Parent = fill

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "NameLabel"
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(0, -18)
	nameLabel.Size = UDim2.fromOffset(110, 16)
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.Text = model.Name
	nameLabel.TextColor3 = Color3.fromRGB(245, 245, 245)
	nameLabel.TextSize = 11
	nameLabel.TextStrokeTransparency = 0.4
	nameLabel.Parent = billboard

	local function update()
		local ratio = 0
		if humanoid.MaxHealth > 0 then
			ratio = math.clamp(humanoid.Health / humanoid.MaxHealth, 0, 1)
		end

		fill.Size = UDim2.fromScale(ratio, 1)
		if ratio > 0.55 then
			fill.BackgroundColor3 = Color3.fromRGB(70, 210, 95)
		elseif ratio > 0.25 then
			fill.BackgroundColor3 = Color3.fromRGB(235, 185, 55)
		else
			fill.BackgroundColor3 = Color3.fromRGB(220, 55, 45)
		end
	end

	humanoid.HealthChanged:Connect(update)
	update()
end

function NPCFactory:CreateHumanoidNPC(name, cframe, color, maxHealth, scale)
	scale = scale or 1

	local model = Instance.new("Model")
	model.Name = name

	local root = makePart("HumanoidRootPart", Vector3.new(2, 2, 1) * scale, color, Enum.Material.Neon)
	root.CFrame = cframe
	root.Anchored = false
	root.CanCollide = false
	root.Transparency = 1
	root.Parent = model

	local body = makePart("Body", Vector3.new(4, 5, 2) * scale, color, Enum.Material.SmoothPlastic)
	body.CFrame = cframe
	body.Parent = model

	local head = makePart("Head", Vector3.new(2.5, 2.5, 2.5) * scale, color:Lerp(Color3.new(1, 1, 1), 0.2), Enum.Material.SmoothPlastic)
	head.CFrame = cframe * CFrame.new(0, 3.75 * scale, 0)
	head.Parent = model

	local humanoid = Instance.new("Humanoid")
	humanoid.MaxHealth = maxHealth
	humanoid.Health = maxHealth
	humanoid.Parent = model

	local rootToBody = Instance.new("WeldConstraint")
	rootToBody.Part0 = root
	rootToBody.Part1 = body
	rootToBody.Parent = root

	local bodyToHead = Instance.new("WeldConstraint")
	bodyToHead.Part0 = body
	bodyToHead.Part1 = head
	bodyToHead.Parent = body

	model.PrimaryPart = root
	addHealthBar(model, head, humanoid)
	return model, humanoid, root
end

return NPCFactory
