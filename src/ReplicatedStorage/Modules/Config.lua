local Config = {}

Config.ActiveAbilitySlots = 10
Config.ActiveSpellSlots = Config.ActiveAbilitySlots
Config.DefaultClass = "Fire Caster"
Config.DefaultMageType = Config.DefaultClass

Config.Map = {
	BaseCount = 16,
	BaseRadius = 260,
	BaseSize = Vector3.new(70, 2, 70),
	SafeZoneHeight = 36,
	ArenaSize = Vector3.new(185, 2, 185),
	SubwayDepth = -46,
}

Config.Combat = {
	DefaultWalkSpeed = 18,
	PlayerMaxHealth = 100,
	RespawnProtectionSeconds = 5,
	KillCreditSeconds = 12,
}

Config.Boss = {
	InitialSpawnSeconds = 60,
	WarningSeconds = 30,
	SpawnMinSeconds = 5 * 60,
	SpawnMaxSeconds = 10 * 60,
	MaxHealth = 900,
	ContactDamage = 18,
	AttackRadius = 18,
	AttackCooldown = 2.5,
	RewardCurrency = 75,
}

Config.Mobs = {
	Count = 8,
	MaxHealth = 90,
	ContactDamage = 10,
	DetectRadius = 85,
	AttackRadius = 7,
	AttackCooldown = 1.4,
	RespawnSeconds = 8,
	WalkSpeed = 13,
	RewardCurrency = 8,
}

return Config
