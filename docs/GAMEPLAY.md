# King of the Trashlands Gameplay

This document is the living description of how the game currently works. Update it whenever gameplay, systems, map layout, or player flow changes.

## Current Pillar

Players spawn in outer safe bases, choose a combat class, run into the Trashlands arena, fight other players with abilities, drop into the subway to fight mobs, and occasionally team up or compete around a boss spawn.

## Current Player Flow

1. A player joins the server.
2. The server assigns them a home base.
3. Roblox spawns them at that home base.
4. The player chooses Fire Caster, Ice Mage, or Lightning Mage.
5. The player receives starter ability tools for that class.
6. Bases protect players from damage.
7. The player leaves the base and enters the central arena.
8. Player abilities can damage other players only when both attacker and target are outside safe zones.
9. The player can enter the subway under the arena to fight mobs.
10. A boss appears periodically in the central arena.
11. Players who damage and defeat mobs or the boss receive placeholder currency.
12. When a player dies, they respawn back at their assigned home base.

## Map

The current map is generated at runtime by `MapService`.

- 16 bases are arranged around the outside of the map.
- Each base has a floor, walls, spawn point, label, and invisible safe-zone volume.
- The center contains the main PvP arena.
- Red neon boundaries mark the central arena area.
- Scrap cover pieces provide simple line-of-sight blockers and obstacles.
- A ramp leads down to the underground subway arena.
- The subway contains walls, cover, a broken train car, and mob spawn points.

## Safe Zones

Safe zones are server-authoritative.

- Safe-zone volumes live in `Workspace.SafeZones`.
- `SafeZoneService` checks whether a player, character, or position is protected.
- `SafeZoneService` publishes each player's safe-zone status to the client for UI feedback.
- If the attacker or target is inside a base safe zone, player ability damage is ignored.
- NPC damage from mobs and bosses is ignored when the target player is in a safe zone.
- Mobs and bosses avoid selecting players who are inside safe zones.
- Players see a top-screen status badge showing `SAFE ZONE` or `PVP ENABLED`.

## Combat

`CombatService` is the central server-side damage gate.

- Player ability damage must go through `CombatService:DamageCharacter`.
- NPC damage must go through `CombatService:DamagePlayerFromNPC`.
- Boss and mob damage ledgers are tracked for reward and cleanup logic.
- Player-versus-player kill credit is tracked from recent player damage.
- Respawn-protected players cannot deal or receive combat damage.
- Validated damage publishes combat feedback to clients.
- Players see floating damage numbers when damage lands.
- Attackers see a hit marker when their spell successfully damages a target.
- Ability casts show simple cooldown bars near the bottom of the screen.
- Ability casts trigger lightweight local cast sound and flash feedback.
- Validated damage triggers lightweight impact pulse and nearby impact sound feedback.
- Boss spawns show a top-screen boss health bar while the boss is active.
- Damage validation should stay on the server even after client UI and aiming improve.

## Player Lifecycle

Player death and respawn behavior is managed by `PlayerLifecycleService`.

- Each player receives a home base assignment when they join.
- Player `RespawnLocation` is set to that base's spawn point.
- On character spawn, the server moves the character to the assigned home base.
- Ability cooldowns are reset when the player respawns.
- A short respawn protection timer prevents the player from dealing or receiving damage.
- Players have `Kills`, `Deaths`, and `TrashCoins` in `leaderstats`.
- Deaths are counted when the character dies.
- Kills are awarded to the recent player attacker when applicable.
- On death, the player sees a short defeated message with killer/source details when available.
- The death message includes a simple respawn countdown display.

## Classes And Abilities

The game currently has three selectable combat classes.

- First-time players must choose a class before receiving ability tools.
- Available mage classes: Fire Caster, Ice Mage, and Lightning Mage.
- Class selection is icon-first: each card shows a large element icon and the class name.
- Players can change class later while inside a base safe zone.
- The server validates class selections against `ClassDefinitions`.
- Configurable active ability slots: 10.
- The older spell/mage names are kept as compatibility aliases while the game moves toward combat classes and abilities.
- Each selected class grants an `AbilityList`; a legacy `SpellList` is also maintained for current scripts.
- Each player receives replicated ability data.
- The server rejects ability casts that are not in the player's active `AbilityList`.
- Starter abilities are currently implemented as Roblox `Tool` instances.
- Tool activation is intentionally disabled for now; the custom hotbar owns player ability input.
- The default Roblox backpack UI is hidden so ability tools do not compete with the custom hotbar.
- Players also get a custom ability hotbar that reads `AbilityList`.
- Keyboard slots use `1` through `0` to select an ability.
- Mouse users cast the selected ability with left click.
- Mobile users tap a hotbar slot to select an ability, then tap the world to cast it.
- Controller users can select through supported UI navigation and cast the selected ability with right trigger.
- The selected ability shows a client-side aiming preview where useful.

## Ability Framework

Abilities are data-driven through `AbilityDefinitions`.

- `AbilityType` describes the broad behavior category, such as projectile, melee, dash, trap, summon, or shield.
- `Targeting` describes how the ability finds targets. Current supported targeting modes are `ForwardRay`, `SelfArea`, and `SelfBuff`.
- `ForwardRay` uses the player's pointer/camera aim position when available, then the server clamps the ray to the ability range.
- Desktop mouse aiming uses the cursor position.
- Touch and gamepad aiming use the center of the camera view.
- Selected `ForwardRay` abilities show a local preview line from the player toward the current aim point.
- Selected `SelfArea` abilities show a local radius preview around the player.
- Selected `SelfBuff` abilities do not show a world target preview.
- `SelfArea` damages valid targets around the caster through server-side combat validation.
- `SelfBuff` applies temporary self-only buffs such as health shield or speed.
- `Damage`, `Range`, and `Cooldown` tune the current direct-hit abilities.
- `Effects` is a data table reserved for future burn, slow, bleed, shield, knockback, stun, and other effects.
- `Tags` describe themes and mechanics, such as magic, fire, ranged, tech, melee, or defensive.
- `Visual` describes the temporary server-created cast effect, including shape, width, lifetime, material, and secondary color.
- `Audio` describes simple client-side cast and impact sounds for ability feedback.
- `CastAbility` is the new remote/service path. `CastSpell` remains for compatibility.

Current Fire Caster abilities:

- Fireball
- Flame Burst: area burst around the caster.
- Ignite

Current Ice Mage abilities:

- Ice Shard
- Frost Bolt
- Ice Armor: temporary self shield.

Current Lightning Mage abilities:

- Lightning Bolt
- Spark Shot
- Blink Surge: temporary speed buff.

Planned expansion:

- Up to 10 active ability slots per class build.
- Ability trees with unlockable abilities and upgrades.
- Ability-specific status effects and passives.
- Non-mage combat classes such as Scrap Knight, Tech Warrior, Toxic Scavenger, and Junk Engineer.

## Mobs

Subway mobs are managed by `MobService`.

- Mobs spawn from `Workspace.MobSpawns`.
- Mobs chase nearby players outside safe zones.
- Mobs attack nearby players with simple contact-range damage.
- Mobs can be damaged by player abilities.
- Mobs respawn after death.
- Mobs have overhead health bars.
- Players who contributed damage to a defeated mob receive `TrashCoins`.
- Mob rewards are placeholder tuning and currently use a flat configured amount per contributor.

## Boss

The boss is managed by `BossService`.

- First boss spawn happens after 60 seconds for testing.
- Later boss spawns use a random 5-10 minute timer.
- A boss warning appears before spawn.
- The current boss spawns at the center arena.
- The boss has health, chases nearby players, and attacks players outside safe zones.
- Players who contributed damage receive placeholder `TrashCoins` when the boss dies.
- Boss contributors receive a reward popup when the boss dies.
- The boss has an overhead health bar.
- The boss also has a top-screen health UI while active.

Planned expansion:

- Multiple boss spawn locations.
- Underground boss spawns.
- Boss types, abilities, phases, and encounter warnings.
- Better rewards and loot tables.

## Current Technical Structure

- `ServerScriptService/GameManager.server.lua`: boots services.
- `ServerScriptService/MapService.lua`: generates the map, bases, arena, subway, spawns, and remotes.
- `ServerScriptService/SafeZoneService.lua`: reusable safe-zone checks.
- `ServerScriptService/CombatService.lua`: server-side damage validation.
- `ServerScriptService/ClassService.lua`: player class attributes, ability lists, and starter ability tools.
- `ServerScriptService/MageService.lua`: compatibility alias for `ClassService`.
- `ServerScriptService/PlayerLifecycleService.lua`: home base assignment, respawn placement, respawn protection, and kill/death stats.
- `ServerScriptService/SpellService.lua`: ability casting, cooldowns, raycasts, and effects.
- `ServerScriptService/AbilityService.lua`: compatibility alias for the ability service path.
- `ServerScriptService/MobService.lua`: subway mob spawning, chase, attack, and respawn.
- `ServerScriptService/BossService.lua`: timed boss spawning, boss AI, and rewards.
- `StarterPlayer/StarterPlayerScripts/SafeZoneFeedback.client.lua`: client status badge for safe-zone and PvP state.
- `StarterPlayer/StarterPlayerScripts/CombatFeedback.client.lua`: floating damage numbers, hit marker, death messages, respawn countdown display, cast flashes, cast sounds, impact pulses, impact sounds, reward popups, boss health UI, and spell cooldown feedback.
- `StarterPlayer/StarterPlayerScripts/AbilityCasting.client.lua`: compatibility placeholder; direct tool activation is disabled.
- `StarterPlayer/StarterPlayerScripts/AbilityHotbar.client.lua`: custom ability slots, keyboard/touch selection, selected-ability casting, aiming previews, and cooldown overlays.
- `StarterPlayer/StarterPlayerScripts/BossAlert.client.lua`: boss warning, spawn, and defeated banners.
- `StarterPlayer/StarterPlayerScripts/ClassSelection.client.lua`: first-time class selection and safe-zone class changing.
- `ReplicatedStorage/Modules/Config.lua`: shared tuning values.
- `ReplicatedStorage/Modules/ClassDefinitions.lua`: primary class definitions.
- `ReplicatedStorage/Modules/AbilityDefinitions.lua`: primary ability definitions.
- `ReplicatedStorage/Modules/MageDefinitions.lua`: compatibility alias for `ClassDefinitions`.
- `ReplicatedStorage/Modules/SpellDefinitions.lua`: compatibility alias for `AbilityDefinitions`.
