local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local Config = require(ReplicatedStorage.Modules.Config)
local ClassDefinitions = require(ReplicatedStorage.Modules.ClassDefinitions)
local SafeZoneService = require(ServerScriptService.SafeZoneService)
local AbilityService = require(ServerScriptService.AbilityService)

local ClassService = {
	ClassSelectionStatus = nil,
}

function ClassService:Init()
	local remotes = ReplicatedStorage:WaitForChild("Remotes")
	local selectClass = remotes:WaitForChild("SelectClass")
	local selectMage = remotes:WaitForChild("SelectMage")
	self.ClassSelectionStatus = remotes:WaitForChild("ClassSelectionStatus")

	selectClass.OnServerEvent:Connect(function(player, className)
		self:SelectClass(player, className)
	end)

	selectMage.OnServerEvent:Connect(function(player, className)
		self:SelectClass(player, className)
	end)

	Players.PlayerAdded:Connect(function(player)
		self:SetupPlayer(player)
	end)

	for _, player in ipairs(Players:GetPlayers()) do
		self:SetupPlayer(player)
	end
end

function ClassService:SetupPlayer(player)
	if player:GetAttribute("CombatClass") == nil then
		local legacyMageType = player:GetAttribute("MageType")
		player:SetAttribute("CombatClass", legacyMageType or Config.DefaultClass)
	end

	player:SetAttribute("MageType", player:GetAttribute("CombatClass"))
	player:SetAttribute("CombatClassSelected", player:GetAttribute("CombatClassSelected") == true or player:GetAttribute("MageTypeSelected") == true)
	player:SetAttribute("MageTypeSelected", player:GetAttribute("CombatClassSelected") == true)
	player:SetAttribute("ActiveAbilitySlots", Config.ActiveAbilitySlots)
	player:SetAttribute("ActiveSpellSlots", Config.ActiveAbilitySlots)

	self:SetupLeaderstats(player)

	if player:GetAttribute("ClassSetupComplete") then
		return
	end

	player:SetAttribute("ClassSetupComplete", true)
	player:SetAttribute("MageSetupComplete", true)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.MaxHealth = Config.Combat.PlayerMaxHealth
		humanoid.Health = humanoid.MaxHealth
		humanoid.WalkSpeed = Config.Combat.DefaultWalkSpeed

		task.defer(function()
			self:GiveAbilityTools(player)
		end)
	end)

	if player.Character then
		self:GiveAbilityTools(player)
	end
end

function ClassService:SetupLeaderstats(player)
	local leaderstats = player:FindFirstChild("leaderstats")
	if not leaderstats then
		leaderstats = Instance.new("Folder")
		leaderstats.Name = "leaderstats"
		leaderstats.Parent = player
	end

	if not leaderstats:FindFirstChild("TrashCoins") then
		local currency = Instance.new("IntValue")
		currency.Name = "TrashCoins"
		currency.Value = 0
		currency.Parent = leaderstats
	end
end

function ClassService:SelectClass(player, className)
	if typeof(className) ~= "string" then
		self:SendSelectionStatus(player, false, "Invalid class selection.")
		return false
	end

	local classDefinition = ClassDefinitions[className]
	if not classDefinition or not classDefinition.Selectable then
		self:SendSelectionStatus(player, false, "That class is not available yet.")
		return false
	end

	if player:GetAttribute("CombatClassSelected") and not SafeZoneService:IsPlayerInSafeZone(player) then
		self:SendSelectionStatus(player, false, "Change class inside a base safe zone.")
		return false
	end

	player:SetAttribute("CombatClass", className)
	player:SetAttribute("MageType", className)
	player:SetAttribute("CombatClassSelected", true)
	player:SetAttribute("MageTypeSelected", true)
	AbilityService:ResetPlayerCooldowns(player)
	self:GiveAbilityTools(player)
	self:SendSelectionStatus(player, true, "Selected " .. classDefinition.DisplayName .. ".")
	return true
end

function ClassService:SelectMage(player, mageType)
	return self:SelectClass(player, mageType)
end

function ClassService:SendSelectionStatus(player, success, message)
	if self.ClassSelectionStatus then
		self.ClassSelectionStatus:FireClient(player, success, message)
	end

	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	local legacyStatus = remotes and remotes:FindFirstChild("MageSelectionStatus")
	if legacyStatus then
		legacyStatus:FireClient(player, success, message)
	end
end

function ClassService:GiveAbilityTools(player)
	if not player:GetAttribute("CombatClassSelected") then
		self:ClearAbilityTools(player)
		return
	end

	self:ClearAbilityTools(player)
	local backpack = player:WaitForChild("Backpack")

	local abilityList = self:GetOrCreateList(player, "AbilityList")
	abilityList:ClearAllChildren()

	local spellList = self:GetOrCreateList(player, "SpellList")
	spellList:ClearAllChildren()

	local className = player:GetAttribute("CombatClass") or Config.DefaultClass
	local classDefinition = ClassDefinitions[className] or ClassDefinitions[Config.DefaultClass]
	local slots = player:GetAttribute("ActiveAbilitySlots") or Config.ActiveAbilitySlots
	local starterAbilities = classDefinition.StarterAbilities or {}

	for index, abilityName in ipairs(starterAbilities) do
		if index > slots then
			break
		end

		local abilityValue = Instance.new("StringValue")
		abilityValue.Name = "Slot " .. index
		abilityValue.Value = abilityName
		abilityValue.Parent = abilityList

		local spellValue = Instance.new("StringValue")
		spellValue.Name = "Slot " .. index
		spellValue.Value = abilityName
		spellValue.Parent = spellList

		local tool = Instance.new("Tool")
		tool.Name = abilityName
		tool.RequiresHandle = false
		tool.CanBeDropped = false
		tool:SetAttribute("AbilityTool", true)
		tool:SetAttribute("AbilityName", abilityName)
		tool:SetAttribute("SpellTool", true)
		tool:SetAttribute("SpellName", abilityName)
		tool.Parent = backpack

		-- Client tools send aim position through CastAbility. Server still validates
		-- class, active ability list, cooldowns, range, safe zones, and damage.
	end
end

function ClassService:GiveSpellTools(player)
	self:GiveAbilityTools(player)
end

function ClassService:GetOrCreateList(player, listName)
	local list = player:FindFirstChild(listName)
	if not list then
		list = Instance.new("Folder")
		list.Name = listName
		list.Parent = player
	end

	return list
end

function ClassService:ClearAbilityTools(player)
	local abilityList = player:FindFirstChild("AbilityList")
	if abilityList then
		abilityList:ClearAllChildren()
	end

	local spellList = player:FindFirstChild("SpellList")
	if spellList then
		spellList:ClearAllChildren()
	end

	local backpack = player:FindFirstChild("Backpack")
	if backpack then
		self:DestroyAbilityTools(backpack)
	end

	local character = player.Character
	if character then
		self:DestroyAbilityTools(character)
	end
end

function ClassService:ClearSpellTools(player)
	self:ClearAbilityTools(player)
end

function ClassService:DestroyAbilityTools(container)
	for _, item in ipairs(container:GetChildren()) do
		if item:IsA("Tool") and (item:GetAttribute("AbilityTool") or item:GetAttribute("SpellTool")) then
			item:Destroy()
		end
	end
end

return ClassService
