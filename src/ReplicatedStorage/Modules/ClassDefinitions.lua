local ClassDefinitions = {
	["Fire Caster"] = {
		DisplayName = "Fire Caster",
		Archetype = "Mage",
		Element = "Fire",
		Role = "Burst damage",
		Description = "Aggressive caster with simple, high-pressure fire abilities.",
		Selectable = true,
		StarterAbilities = { "Fireball", "Flame Burst", "Ignite" },
	},
	["Lightning Mage"] = {
		DisplayName = "Lightning Mage",
		Archetype = "Mage",
		Element = "Lightning",
		Role = "Speed and precision",
		Description = "Fast striker with long range and quick follow-up abilities.",
		Selectable = true,
		StarterAbilities = { "Lightning Bolt", "Spark Shot", "Blink Surge" },
	},
	["Ice Mage"] = {
		DisplayName = "Ice Mage",
		Archetype = "Mage",
		Element = "Ice",
		Role = "Control and survival",
		Description = "Defensive mage with spreading ice, projectile bursts, and ground control.",
		Selectable = true,
		StarterAbilities = { "Ice Shard", "Frost Bolt", "Ice Nova", "Glacier Spike", "Glacier Path", "Hail Crash", "Ice Armor" },
	},
}

-- Future class examples: Scrap Knight, Tech Warrior, Toxic Scavenger,
-- Junk Engineer, Shadow Duelist. They can share this same shape.

for _, classDefinition in pairs(ClassDefinitions) do
	classDefinition.StarterSpells = classDefinition.StarterAbilities
end

return ClassDefinitions
