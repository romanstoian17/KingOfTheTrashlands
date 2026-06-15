local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local Config = require(ReplicatedStorage.Modules.Config)

local player = Players.LocalPlayer
local extraAirJumps = Config.Movement.ExtraAirJumps or 1
local jumpPowerMultiplier = Config.Movement.DoubleJumpPowerMultiplier or 1

local character = nil
local humanoid = nil
local root = nil
local jumpsUsed = 0
local jumpHeld = false

local groundedStates = {
	[Enum.HumanoidStateType.Landed] = true,
	[Enum.HumanoidStateType.Running] = true,
	[Enum.HumanoidStateType.RunningNoPhysics] = true,
	[Enum.HumanoidStateType.Swimming] = true,
	[Enum.HumanoidStateType.Climbing] = true,
}

local airborneStates = {
	[Enum.HumanoidStateType.Freefall] = true,
	[Enum.HumanoidStateType.FallingDown] = true,
}

local function isAirborne()
	if not humanoid then
		return false
	end

	return airborneStates[humanoid:GetState()] == true or humanoid.FloorMaterial == Enum.Material.Air
end

local function resetAirJumps()
	jumpsUsed = 0
	jumpHeld = false
end

local function getJumpVelocity()
	if not humanoid then
		return 50
	end

	if humanoid.UseJumpPower then
		return humanoid.JumpPower * jumpPowerMultiplier
	end

	return math.sqrt(2 * workspace.Gravity * humanoid.JumpHeight) * jumpPowerMultiplier
end

local function doExtraJump()
	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	jumpsUsed += 1
	humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

	local velocity = root.AssemblyLinearVelocity
	root.AssemblyLinearVelocity = Vector3.new(velocity.X, getJumpVelocity(), velocity.Z)
end

local function onJumpRequest()
	if jumpHeld then
		return
	end

	jumpHeld = true
	task.delay(0.18, function()
		jumpHeld = false
	end)

	if not humanoid or not root or humanoid.Health <= 0 then
		return
	end

	if not isAirborne() then
		return
	end

	if jumpsUsed < extraAirJumps then
		doExtraJump()
	end
end

local function onCharacterAdded(newCharacter)
	character = newCharacter
	humanoid = character:WaitForChild("Humanoid")
	root = character:WaitForChild("HumanoidRootPart")
	resetAirJumps()

	humanoid.StateChanged:Connect(function(_, newState)
		if groundedStates[newState] then
			resetAirJumps()
		end
	end)

	humanoid.Died:Connect(resetAirJumps)
end

UserInputService.JumpRequest:Connect(onJumpRequest)

if player.Character then
	onCharacterAdded(player.Character)
end

player.CharacterAdded:Connect(onCharacterAdded)
