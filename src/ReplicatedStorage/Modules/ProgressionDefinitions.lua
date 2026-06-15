local ProgressionDefinitions = {}

ProgressionDefinitions.Currencies = {
	TrashCoins = {
		DisplayName = "TrashCoins",
		Rarity = "Common",
		Use = "Basic purchases, starter upgrades, and everyday rewards.",
	},
	ScrapCores = {
		DisplayName = "Scrap Cores",
		Rarity = "Uncommon",
		Use = "Advanced upgrades, class training, and dungeon rewards.",
	},
	RoyalShards = {
		DisplayName = "Royal Shards",
		Rarity = "Rare",
		Use = "Perfect upgrades, high-tier unlocks, and boss rewards.",
	},
}

ProgressionDefinitions.Rewards = {
	Daily = {
		TrashCoins = 25,
		ScrapCores = 0,
		RoyalShards = 0,
	},
	FirstArenaVisit = {
		TrashCoins = 15,
	},
	FirstSubwayVisit = {
		TrashCoins = 20,
	},
	FirstMobDefeat = {
		TrashCoins = 20,
		ScrapCores = 1,
	},
	BossContribution = {
		TrashCoins = 75,
		ScrapCores = 2,
		RoyalShards = 0,
	},
}

ProgressionDefinitions.BeginnerGoals = {
	{ Id = "ChooseClass", Text = "Choose any class.", Reward = { TrashCoins = 10 } },
	{ Id = "EnterArena", Text = "Reach the center arena.", Reward = ProgressionDefinitions.Rewards.FirstArenaVisit },
	{ Id = "EnterSubway", Text = "Find a subway entrance.", Reward = ProgressionDefinitions.Rewards.FirstSubwayVisit },
	{ Id = "DefeatMob", Text = "Help defeat one subway mob.", Reward = ProgressionDefinitions.Rewards.FirstMobDefeat },
	{ Id = "SeeBoss", Text = "Join a boss fight.", Reward = { TrashCoins = 25 } },
}

ProgressionDefinitions.Passives = {
	ToughSkin = {
		DisplayName = "Tough Skin",
		MaxLevel = 5,
		Effect = "Increase max health.",
	},
	ScrapCollector = {
		DisplayName = "Scrap Collector",
		MaxLevel = 5,
		Effect = "Increase common currency rewards.",
	},
	FrostCore = {
		DisplayName = "Frost Core",
		MaxLevel = 5,
		Effect = "Improve Ice Mage shield and area control.",
	},
}

ProgressionDefinitions.ClassUnlocks = {
	DefaultUnlocked = "All current classes are available for testing.",
	FutureRule = "Advanced classes may later require TrashCoins, ScrapCores, RoyalShards, boss drops, or prerequisite class levels.",
}

ProgressionDefinitions.SpellTree = {
	MaxActiveSlots = 10,
	FutureRule = "Each class can branch into ability upgrades, passive nodes, and unlockable active abilities.",
	ExampleUpgrade = {
		AbilityName = "Fireball",
		UpgradeName = "Bigger Blast",
		Effect = "Increase explosion radius while keeping damage balanced.",
	},
}

ProgressionDefinitions.LootTables = {
	Mob = {
		{ Currency = "TrashCoins", Min = 5, Max = 10 },
	},
	Boss = {
		{ Currency = "TrashCoins", Min = 60, Max = 90 },
		{ Currency = "ScrapCores", Min = 1, Max = 3 },
	},
}

ProgressionDefinitions.EconomyNotes = {
	"Early rewards should feel generous enough to teach the loop.",
	"Rare resources should come mostly from bosses, weekly goals, or deeper dungeon content.",
	"Keep all classes available during prototype testing before locking anything.",
}

return ProgressionDefinitions
