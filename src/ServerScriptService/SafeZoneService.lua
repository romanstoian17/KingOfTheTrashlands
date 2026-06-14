local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SafeZoneService = {
	Zones = {},
	PlayerStates = {},
}

function SafeZoneService:Init()
	self:RefreshZones()

	local safeZones = Workspace:WaitForChild("SafeZones")
	safeZones.ChildAdded:Connect(function()
		self:RefreshZones()
	end)
	safeZones.ChildRemoved:Connect(function()
		self:RefreshZones()
	end)

	Players.PlayerRemoving:Connect(function(player)
		self.PlayerStates[player.UserId] = nil
	end)

	task.spawn(function()
		self:RunPlayerStatusLoop()
	end)
end

function SafeZoneService:RefreshZones()
	table.clear(self.Zones)

	local safeZones = Workspace:FindFirstChild("SafeZones")
	if not safeZones then
		return
	end

	for _, zone in ipairs(safeZones:GetChildren()) do
		if zone:IsA("BasePart") and zone:GetAttribute("SafeZone") then
			table.insert(self.Zones, zone)
		end
	end
end

function SafeZoneService:IsPositionInSafeZone(position)
	for _, zone in ipairs(self.Zones) do
		local localPosition = zone.CFrame:PointToObjectSpace(position)
		local halfSize = zone.Size * 0.5

		if math.abs(localPosition.X) <= halfSize.X
			and math.abs(localPosition.Y) <= halfSize.Y
			and math.abs(localPosition.Z) <= halfSize.Z then
			return true, zone
		end
	end

	return false, nil
end

function SafeZoneService:IsCharacterInSafeZone(character)
	if not character then
		return false
	end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end

	return self:IsPositionInSafeZone(root.Position)
end

function SafeZoneService:IsPlayerInSafeZone(player)
	if not player or not player:IsA("Player") then
		return false
	end

	return self:IsCharacterInSafeZone(player.Character)
end

function SafeZoneService:GetZoneDisplayName(zone)
	if not zone then
		return nil
	end

	local baseIndex = zone:GetAttribute("BaseIndex")
	if baseIndex then
		return "Base " .. baseIndex
	end

	return zone.Name
end

function SafeZoneService:RunPlayerStatusLoop()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local safeZoneStatus = remotes:WaitForChild("SafeZoneStatus")

	while true do
		for _, player in ipairs(Players:GetPlayers()) do
			local inSafeZone, zone = self:IsPlayerInSafeZone(player)
			local zoneName = self:GetZoneDisplayName(zone)
			local previous = self.PlayerStates[player.UserId]

			if not previous or previous.InSafeZone ~= inSafeZone or previous.ZoneName ~= zoneName then
				self.PlayerStates[player.UserId] = {
					InSafeZone = inSafeZone,
					ZoneName = zoneName,
				}

				player:SetAttribute("InSafeZone", inSafeZone)
				player:SetAttribute("CurrentSafeZoneName", zoneName)
				safeZoneStatus:FireClient(player, inSafeZone, zoneName)
			end
		end

		task.wait(0.2)
	end
end

function SafeZoneService:GetPlayerFromCharacter(character)
	if not character then
		return nil
	end

	return Players:GetPlayerFromCharacter(character)
end

return SafeZoneService
