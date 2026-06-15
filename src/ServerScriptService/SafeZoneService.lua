local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local SafeZoneService = {
	Zones = {},
	ExitZones = {},
	PlayerStates = {},
}

function SafeZoneService:Init()
	self:RefreshZones()

	local safeZones = Workspace:WaitForChild("SafeZones")
	local exitProtectionZones = Workspace:WaitForChild("ExitProtectionZones")
	safeZones.ChildAdded:Connect(function()
		self:RefreshZones()
	end)
	safeZones.ChildRemoved:Connect(function()
		self:RefreshZones()
	end)
	exitProtectionZones.ChildAdded:Connect(function()
		self:RefreshZones()
	end)
	exitProtectionZones.ChildRemoved:Connect(function()
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
	table.clear(self.ExitZones)

	local safeZones = Workspace:FindFirstChild("SafeZones")
	if not safeZones then
		return
	end

	for _, zone in ipairs(safeZones:GetChildren()) do
		if zone:IsA("BasePart") and zone:GetAttribute("SafeZone") then
			table.insert(self.Zones, zone)
		end
	end

	local exitProtectionZones = Workspace:FindFirstChild("ExitProtectionZones")
	if not exitProtectionZones then
		return
	end

	for _, zone in ipairs(exitProtectionZones:GetChildren()) do
		if zone:IsA("BasePart") and zone:GetAttribute("ExitProtectionZone") then
			table.insert(self.ExitZones, zone)
		end
	end
end

function SafeZoneService:IsPositionInsideZoneList(position, zones)
	for _, zone in ipairs(zones) do
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

function SafeZoneService:IsPositionInSafeZone(position)
	return self:IsPositionInsideZoneList(position, self.Zones)
end

function SafeZoneService:IsPositionInExitProtectionZone(position)
	return self:IsPositionInsideZoneList(position, self.ExitZones)
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

function SafeZoneService:IsPlayerInOwnExitProtectionZone(player)
	if not player or not player:IsA("Player") or not player.Character then
		return false, nil
	end

	local root = player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false, nil
	end

	local inExitZone, zone = self:IsPositionInExitProtectionZone(root.Position)
	if not inExitZone or not zone then
		return false, nil
	end

	if zone:GetAttribute("BaseIndex") ~= player:GetAttribute("HomeBaseIndex") then
		return false, nil
	end

	return true, zone
end

function SafeZoneService:IsPlayerExitProtected(player)
	local protectedUntil = player and player:GetAttribute("ExitProtectedUntil")
	if typeof(protectedUntil) ~= "number" or os.clock() >= protectedUntil then
		return false, nil
	end

	local inSafeZone, safeZone = self:IsPlayerInSafeZone(player)
	if inSafeZone and safeZone and safeZone:GetAttribute("BaseIndex") == player:GetAttribute("HomeBaseIndex") then
		return true, safeZone
	end

	return self:IsPlayerInOwnExitProtectionZone(player)
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
			local exitProtected, exitZone = self:IsPlayerExitProtected(player)
			local zoneName = self:GetZoneDisplayName(zone)
			local exitZoneName = self:GetZoneDisplayName(exitZone)
			local previous = self.PlayerStates[player.UserId]
			local statusMode = exitProtected and "ExitProtection" or (inSafeZone and "SafeZone" or "PvP")

			if not previous or previous.InSafeZone ~= inSafeZone or previous.ExitProtected ~= exitProtected or previous.ZoneName ~= zoneName or previous.StatusMode ~= statusMode then
				self.PlayerStates[player.UserId] = {
					InSafeZone = inSafeZone,
					ExitProtected = exitProtected,
					ZoneName = zoneName,
					StatusMode = statusMode,
				}

				player:SetAttribute("InSafeZone", inSafeZone)
				player:SetAttribute("InExitProtection", exitProtected)
				player:SetAttribute("CurrentSafeZoneName", zoneName)
				safeZoneStatus:FireClient(player, inSafeZone or exitProtected, exitProtected and (exitZoneName or "Base exit") or zoneName, statusMode)
			end

			local protectedUntil = player:GetAttribute("ExitProtectedUntil")
			if typeof(protectedUntil) == "number" and os.clock() < protectedUntil and not inSafeZone and not exitProtected then
				player:SetAttribute("ExitProtectedUntil", nil)
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
