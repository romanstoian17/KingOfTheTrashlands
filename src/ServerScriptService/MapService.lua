local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Config = require(ReplicatedStorage.Modules.Config)

local MapService = {}

local function makeFolder(parent, name)
	local existing = parent:FindFirstChild(name)
	if existing then
		existing:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = name
	folder.Parent = parent
	return folder
end

local function makePart(parent, name, size, cframe, color, transparency, material)
	local part = Instance.new("Part")
	part.Name = name
	part.Anchored = true
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Transparency = transparency or 0
	part.Material = material or Enum.Material.SmoothPlastic
	part.TopSurface = Enum.SurfaceType.Smooth
	part.BottomSurface = Enum.SurfaceType.Smooth
	part.Parent = parent
	return part
end

local function makeLabel(parent, text, cframe)
	local sign = makePart(parent, text .. " Sign", Vector3.new(26, 10, 1), cframe, Color3.fromRGB(35, 35, 35), 0, Enum.Material.Metal)
	local gui = Instance.new("SurfaceGui")
	gui.Face = Enum.NormalId.Front
	gui.SizingMode = Enum.SurfaceGuiSizingMode.PixelsPerStud
	gui.PixelsPerStud = 32
	gui.Parent = sign

	local label = Instance.new("TextLabel")
	label.BackgroundTransparency = 1
	label.Size = UDim2.fromScale(1, 1)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(235, 255, 235)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = gui
end

local function makeSpawn(parent, name, cframe)
	local spawnLocation = Instance.new("SpawnLocation")
	spawnLocation.Name = name
	spawnLocation.Anchored = true
	spawnLocation.Size = Vector3.new(10, 1, 10)
	spawnLocation.CFrame = cframe
	spawnLocation.Neutral = true
	spawnLocation.AllowTeamChangeOnTouch = false
	spawnLocation.Duration = 0
	spawnLocation.Color = Color3.fromRGB(120, 255, 150)
	spawnLocation.Material = Enum.Material.Neon
	spawnLocation.Parent = parent
	return spawnLocation
end

function MapService:Init()
	local map = makeFolder(Workspace, "GeneratedMap")
	local bases = makeFolder(Workspace, "Bases")
	local arena = makeFolder(Workspace, "Arena")
	local subway = makeFolder(Workspace, "Subway")
	local safeZones = makeFolder(Workspace, "SafeZones")
	local bossSpawns = makeFolder(Workspace, "BossSpawns")
	local mobSpawns = makeFolder(Workspace, "MobSpawns")

	makePart(map, "Trashlands Ground", Vector3.new(620, 2, 620), CFrame.new(0, -1.2, 0), Color3.fromRGB(76, 83, 66), 0, Enum.Material.Ground)

	self:CreateArena(arena, bossSpawns)
	self:CreateBases(bases, safeZones)
	self:CreateSubway(subway, mobSpawns)
	self:CreateRemotes()
end

function MapService:CreateArena(arena, bossSpawns)
	local arenaSize = Config.Map.ArenaSize
	makePart(arena, "Central PvP Arena", arenaSize, CFrame.new(0, 0, 0), Color3.fromRGB(95, 92, 85), 0, Enum.Material.Concrete)

	local borderColor = Color3.fromRGB(190, 45, 45)
	makePart(arena, "North Arena Boundary", Vector3.new(arenaSize.X, 3, 3), CFrame.new(0, 1.5, -arenaSize.Z / 2), borderColor, 0, Enum.Material.Neon)
	makePart(arena, "South Arena Boundary", Vector3.new(arenaSize.X, 3, 3), CFrame.new(0, 1.5, arenaSize.Z / 2), borderColor, 0, Enum.Material.Neon)
	makePart(arena, "East Arena Boundary", Vector3.new(3, 3, arenaSize.Z), CFrame.new(arenaSize.X / 2, 1.5, 0), borderColor, 0, Enum.Material.Neon)
	makePart(arena, "West Arena Boundary", Vector3.new(3, 3, arenaSize.Z), CFrame.new(-arenaSize.X / 2, 1.5, 0), borderColor, 0, Enum.Material.Neon)

	for i = 1, 10 do
		local angle = (math.pi * 2 / 10) * i
		local radius = 28 + (i % 2) * 18
		local position = Vector3.new(math.cos(angle) * radius, 4, math.sin(angle) * radius)
		makePart(arena, "Scrap Cover " .. i, Vector3.new(14, 8 + (i % 3) * 4, 8), CFrame.new(position) * CFrame.Angles(0, angle, 0), Color3.fromRGB(100, 87, 72), 0, Enum.Material.CorrodedMetal)
	end

	makePart(arena, "Subway Entrance Ramp", Vector3.new(24, 3, 70), CFrame.new(-55, -12, 30) * CFrame.Angles(math.rad(-22), 0, 0), Color3.fromRGB(45, 45, 48), 0, Enum.Material.Asphalt)

	local spawn = makePart(bossSpawns, "CenterBossSpawn", Vector3.new(8, 1, 8), CFrame.new(0, 2, 0), Color3.fromRGB(255, 70, 70), 0.25, Enum.Material.Neon)
	spawn:SetAttribute("BossSpawn", true)
end

function MapService:CreateBases(bases, safeZones)
	local baseCount = Config.Map.BaseCount
	local radius = Config.Map.BaseRadius
	local size = Config.Map.BaseSize

	for i = 1, baseCount do
		local angle = (math.pi * 2 / baseCount) * (i - 1)
		local x = math.cos(angle) * radius
		local z = math.sin(angle) * radius
		local baseFolder = Instance.new("Folder")
		baseFolder.Name = "Base " .. i
		baseFolder.Parent = bases

		local baseCFrame = CFrame.lookAt(Vector3.new(x, 0, z), Vector3.new(0, 0, 0))
		makePart(baseFolder, "Base " .. i .. " Floor", size, baseCFrame, Color3.fromRGB(58, 82, 64), 0, Enum.Material.Concrete)
		makePart(baseFolder, "Back Wall", Vector3.new(size.X, 18, 4), baseCFrame * CFrame.new(0, 9, size.Z / 2 - 2), Color3.fromRGB(44, 55, 48), 0, Enum.Material.Brick)
		makePart(baseFolder, "Left Wall", Vector3.new(4, 18, size.Z), baseCFrame * CFrame.new(-size.X / 2 + 2, 9, 0), Color3.fromRGB(44, 55, 48), 0, Enum.Material.Brick)
		makePart(baseFolder, "Right Wall", Vector3.new(4, 18, size.Z), baseCFrame * CFrame.new(size.X / 2 - 2, 9, 0), Color3.fromRGB(44, 55, 48), 0, Enum.Material.Brick)
		local spawn = makeSpawn(baseFolder, "Base " .. i .. " Spawn", baseCFrame * CFrame.new(0, 3, -10))
		spawn:SetAttribute("BaseIndex", i)
		makeLabel(baseFolder, "Base " .. i, baseCFrame * CFrame.new(0, 12, -size.Z / 2 - 1) * CFrame.Angles(0, math.pi, 0))

		local zone = makePart(safeZones, "Base " .. i .. " SafeZone", Vector3.new(size.X, Config.Map.SafeZoneHeight, size.Z), baseCFrame * CFrame.new(0, Config.Map.SafeZoneHeight / 2, 0), Color3.fromRGB(80, 255, 120), 0.8, Enum.Material.ForceField)
		zone.CanCollide = false
		zone:SetAttribute("SafeZone", true)
		zone:SetAttribute("BaseIndex", i)
	end
end

function MapService:CreateSubway(subway, mobSpawns)
	local y = Config.Map.SubwayDepth
	makePart(subway, "Subway Arena Floor", Vector3.new(150, 2, 150), CFrame.new(0, y, 0), Color3.fromRGB(38, 41, 45), 0, Enum.Material.Asphalt)
	makePart(subway, "Subway North Wall", Vector3.new(150, 24, 4), CFrame.new(0, y + 12, -75), Color3.fromRGB(28, 29, 31), 0, Enum.Material.Concrete)
	makePart(subway, "Subway South Wall", Vector3.new(150, 24, 4), CFrame.new(0, y + 12, 75), Color3.fromRGB(28, 29, 31), 0, Enum.Material.Concrete)
	makePart(subway, "Subway East Wall", Vector3.new(4, 24, 150), CFrame.new(75, y + 12, 0), Color3.fromRGB(28, 29, 31), 0, Enum.Material.Concrete)
	makePart(subway, "Subway West Wall", Vector3.new(4, 24, 150), CFrame.new(-75, y + 12, 0), Color3.fromRGB(28, 29, 31), 0, Enum.Material.Concrete)

	makePart(subway, "Broken Train Car", Vector3.new(70, 14, 18), CFrame.new(18, y + 8, 10), Color3.fromRGB(88, 74, 58), 0, Enum.Material.CorrodedMetal)
	makePart(subway, "Platform Cover A", Vector3.new(24, 8, 10), CFrame.new(-42, y + 5, -38), Color3.fromRGB(64, 64, 68), 0, Enum.Material.Concrete)
	makePart(subway, "Platform Cover B", Vector3.new(22, 8, 10), CFrame.new(45, y + 5, 42), Color3.fromRGB(64, 64, 68), 0, Enum.Material.Concrete)

	for i = 1, Config.Mobs.Count do
		local angle = (math.pi * 2 / Config.Mobs.Count) * i
		local spawn = makePart(mobSpawns, "MobSpawn " .. i, Vector3.new(5, 1, 5), CFrame.new(math.cos(angle) * 45, y + 2, math.sin(angle) * 45), Color3.fromRGB(170, 80, 255), 0.35, Enum.Material.Neon)
		spawn:SetAttribute("MobSpawn", true)
	end
end

function MapService:CreateRemotes()
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end

	if not remotes:FindFirstChild("CastSpell") then
		local castSpell = Instance.new("RemoteEvent")
		castSpell.Name = "CastSpell"
		castSpell.Parent = remotes
	end

	if not remotes:FindFirstChild("CastAbility") then
		local castAbility = Instance.new("RemoteEvent")
		castAbility.Name = "CastAbility"
		castAbility.Parent = remotes
	end

	if not remotes:FindFirstChild("SafeZoneStatus") then
		local safeZoneStatus = Instance.new("RemoteEvent")
		safeZoneStatus.Name = "SafeZoneStatus"
		safeZoneStatus.Parent = remotes
	end

	if not remotes:FindFirstChild("CombatFeedback") then
		local combatFeedback = Instance.new("RemoteEvent")
		combatFeedback.Name = "CombatFeedback"
		combatFeedback.Parent = remotes
	end

	if not remotes:FindFirstChild("BossAlert") then
		local bossAlert = Instance.new("RemoteEvent")
		bossAlert.Name = "BossAlert"
		bossAlert.Parent = remotes
	end

	if not remotes:FindFirstChild("SelectMage") then
		local selectMage = Instance.new("RemoteEvent")
		selectMage.Name = "SelectMage"
		selectMage.Parent = remotes
	end

	if not remotes:FindFirstChild("SelectClass") then
		local selectClass = Instance.new("RemoteEvent")
		selectClass.Name = "SelectClass"
		selectClass.Parent = remotes
	end

	if not remotes:FindFirstChild("MageSelectionStatus") then
		local mageSelectionStatus = Instance.new("RemoteEvent")
		mageSelectionStatus.Name = "MageSelectionStatus"
		mageSelectionStatus.Parent = remotes
	end

	if not remotes:FindFirstChild("ClassSelectionStatus") then
		local classSelectionStatus = Instance.new("RemoteEvent")
		classSelectionStatus.Name = "ClassSelectionStatus"
		classSelectionStatus.Parent = remotes
	end
end

return MapService
