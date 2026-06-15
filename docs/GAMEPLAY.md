# King of the Trashlands Gameplay

This document is the living description of how the game currently works. Update it whenever gameplay, systems, map layout, or player flow changes.

## Current Pillar

Players spawn in outer safe bases, choose a combat class, run into the Trashlands arena, fight other players with abilities, drop into the subway to fight mobs, and occasionally team up or compete around a boss spawn.

## Current Player Flow

1. A player joins the server.
2. The server assigns them a home base.
3. Roblox spawns them at that home base.
4. The player chooses one of the currently available combat classes.
5. The player receives starter ability tools for that class.
6. Bases protect players from damage.
7. The player leaves the base and enters the central arena.
8. Player abilities can damage other players only when both attacker and target are outside safe zones.
9. The player can enter the subway under the arena to fight mobs.
10. A boss appears periodically in the central arena or subway.
11. Players who damage and defeat mobs or the boss receive prototype currency rewards.
12. When a player dies, they respawn back at their assigned home base.

## Map

The current map is generated at runtime by `MapService`.

- 16 bases are arranged around the outside of the map.
- Each base has a floor, walls, spawn point, label, and invisible safe-zone volume.
- Each base has a visible exit-protection buffer just outside the base entrance.
- The center contains the main PvP arena.
- Red neon boundaries mark the central arena area.
- Scrap cover pieces provide simple line-of-sight blockers and obstacles.
- A tall arena landmark and `ARENA` sign make the center easier to find.
- Yellow neon path strips and signs lead from bases toward the arena.
- Two marked subway entrance pads in the central arena teleport players down to the underground monster layer.
- Subway signs mark the arena entrances.
- Two marked subway exit pads in the underground layer teleport players back to the central arena.
- The subway contains walls, cover, a broken train car, a larger monster layer floor, and mob spawn points.

Planned map direction:

- Rebuild the test map into a trash-city layout with a large open central fighting space.
- Place buildings, scrap structures, alleys, and cover around the central space so the world feels more like a city than an empty arena.
- Keep bases around the outside, but explore a better base layout than the current simple circle.
- If a better base layout is not ready, keep the outer ring and improve it later.
- Add strong navigation language: visible landmarks, signs, lights, arrows, and route clarity from bases to arena and subway.
- The current city pass keeps a large open central arena, adds roads and trash-city buildings around it, and keeps the 16 bases in the outer ring until a better base layout is designed.

## Safe Zones

Safe zones are server-authoritative.

- Safe-zone volumes live in `Workspace.SafeZones`.
- `SafeZoneService` checks whether a player, character, or position is protected.
- `SafeZoneService` publishes each player's safe-zone status to the client for UI feedback.
- If the attacker or target is inside a base safe zone, player ability damage is ignored.
- NPC damage from mobs and bosses is ignored when the target player is in a safe zone.
- Mobs and bosses avoid selecting players who are inside safe zones.
- Players see a top-screen status badge showing `SAFE ZONE` or `PVP ENABLED`.
- Recently respawned players also receive temporary `EXIT PROTECTION` while they remain in their own base or base exit buffer.
- Exit-protected players cannot deal or receive player, mob, or boss damage.
- Exit protection ends when the player leaves their own base and exit buffer, or when the configured timer expires.

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
- A longer base-exit protection timer helps prevent camping immediately outside the player's home base.
- Players have `Kills`, `Deaths`, and `TrashCoins` in `leaderstats`.
- Deaths are counted when the character dies.
- Kills are awarded to the recent player attacker when applicable.
- On death, the player sees a short defeated message with killer/source details when available.
- The death message includes a simple respawn countdown display.

## Classes And Abilities

The game currently has ten selectable combat classes.

- First-time players must choose a class before receiving ability tools.
- Available classes: Fire Caster, Ice Mage, Lightning Mage, Scrap Knight, Tech Warrior, Toxic Scavenger, Junk Engineer, Shadow Duelist, Stone Guardian, and Wind Runner.
- Class selection is icon-first: each card shows a large element icon and the class name.
- Players can change class later while inside a base safe zone.
- Class switching has a short server-side cooldown.
- Switching class resets ability cooldowns, removes old temporary self buffs, and destroys old class summons.
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
- Players get a simple objective guide that points them toward class selection, the arena, subway entrances, and subway exits.
- A `HELP` panel explains controls, safe zones, class switching, and rewards.
- Keyboard slots use `1` through `0` to select an ability.
- Mouse users cast the selected ability with left click.
- Mobile users tap a hotbar slot to select an ability, then tap the world to cast it.
- Controller users can select through supported UI navigation and cast the selected ability with right trigger.
- The selected ability shows a client-side aiming preview where useful.

## Ability Framework

Abilities are data-driven through `AbilityDefinitions`.

- `AbilityType` describes the broad behavior category, such as projectile, raycast, wave, targeted area, melee, dash, trap, summon, or shield.
- `Targeting` describes how the ability finds targets. Current supported targeting modes are `Raycast`, `MultiRaycast`, `ProjectileExplode`, `SelfArea`, `DelayedSelfArea`, `LineWave`, `TargetedArea`, `Summon`, and `SelfBuff`.
- `Raycast` uses the player's pointer/camera aim position when available, then the server clamps the ray to the ability range.
- `MultiRaycast` fires several server-validated rays in a small spread, making narrow attacks easier to land while keeping total damage controlled.
- `ProjectileExplode` creates a server-owned projectile that travels forward, collides with the world, then damages valid targets in an explosion radius.
- `DelayedSelfArea` spreads outward from the caster over time instead of damaging the full radius instantly.
- `LineWave` grows forward from the caster toward the aimed direction, applying damage along the path as the wave advances.
- `TargetedArea` marks an aimed point, waits briefly, then damages valid targets in that area.
- `Summon` creates a temporary server-owned ally near the aimed point. Summons chase valid enemies, attack through server combat validation, and avoid chasing players protected by bases or exit protection.
- Desktop mouse aiming uses the cursor position.
- Touch and gamepad aiming use the center of the camera view.
- Selected aimed abilities show a local destination marker at the aimed point, clamped to ability range.
- The destination marker scales down for close targets so aiming at nearby cover does not create an oversized preview.
- Selected `SelfArea` abilities do not show a world preview because they fire around the player.
- Selected `SelfBuff` abilities do not show a world target preview.
- `SelfArea` damages valid targets around the caster through server-side combat validation.
- `SelfBuff` applies temporary self-only buffs such as health shield or speed.
- `Damage`, `Range`, and `Cooldown` tune the current direct-hit abilities.
- `Effects` is a data table reserved for future burn, slow, bleed, shield, knockback, stun, and other effects.
- `Tags` describe themes and mechanics, such as magic, fire, ranged, tech, melee, or defensive.
- `Visual` describes the temporary server-created cast effect, including shape, width, lifetime, material, and secondary color.
- `Audio` describes simple client-side cast and impact sounds for ability feedback.
- `UseDifficulty` and `DeviceNotes` describe how easy an ability is to use on mouse, touch, and controller.
- `CastAbility` is the new remote/service path. `CastSpell` remains for compatibility.

Current Fire Caster abilities:

- Fireball: large moving projectile that explodes on impact.
- Flame Burst: area burst around the caster.
- Ignite

Current Ice Mage abilities:

- Ice Shard: three instant raycast shards in a small spread with similar total damage to the old single shard.
- Frost Bolt: moving projectile that bursts on impact.
- Ice Nova: delayed spreading area around the caster with growing ice spikes.
- Glacier Spike: heavier instant raycast spike.
- Glacier Path: forward ice wave that grows from the caster toward the target direction.
- Hail Crash: delayed targeted area burst.
- Ice Armor: temporary self shield.
- Ice Warden: temporary summoned ice ally that attacks nearby valid enemies.

Current Lightning Mage abilities:

- Lightning Bolt
- Spark Shot
- Blink Surge: temporary speed buff.

Additional prototype classes:

- Scrap Knight: tanky scrap brawler with shields, slams, tosses, and ground waves.
- Tech Warrior: gadget fighter with shots, rockets, mines, drone buddy, and tech fields.
- Toxic Scavenger: area-control fighter with sludge, toxic clouds, waste waves, and traps.
- Junk Engineer: builder-style class with turret, fixer bot, traps, fields, and utility.
- Shadow Duelist: fast duelist with shadow bolts, clones, slashes, and dark bursts.
- Stone Guardian: defensive earth fighter with rocks, shields, ground pounds, and boulders.
- Wind Runner: mobile air fighter with gusts, dashes, wind walls, and wide air attacks.

Planned expansion:

- Up to 10 active ability slots per class build.
- Ability trees with unlockable abilities and upgrades.
- Ability-specific status effects and passives.
- Non-mage combat classes such as Scrap Knight, Tech Warrior, Toxic Scavenger, and Junk Engineer.
- For now, all implemented classes should be available to every player.
- Class switching should be allowed through a clear safe-zone flow, with server-side validation, switch cooldowns, cooldown resets, old buff cleanup, and old summon cleanup.
- Combat should be tuned for young players: abilities should be generous enough to hit with through bigger projectiles, multi-projectile spreads, wider waves, forgiving areas, or helpful summons while keeping total damage balanced.
- Ability effects should feel cool, impressive, and readable, with stronger projectile trails, impact bursts, area buildup, summon moments, and cast animations as the game grows.
- New systems should be checked on mouse, touch, and controller before we consider them finished.
- Ability VFX should have a performance budget so the game still runs well when multiple players fight at once.

Planned class roster expansion:

- Add 7 more available classes beyond Fire Caster, Ice Mage, and Lightning Mage.
- Each class should have at least 8 planned abilities.
- Each planned ability should document behavior, damage, cooldown, range, visual effect, and animation idea before or during implementation.
- Example tuning direction: Fireball can become a larger single projectile; Ice Shard can become three smaller shards with total damage close to the current single shard.

Research-informed priorities:

- Improve first-session onboarding so players quickly understand class selection, safe zones, the arena, subway entrances, mobs, bosses, and rewards.
- Make controls and UI comfortable on mobile and controller, not only keyboard and mouse.
- Add analytics and playtest counters for class choices, deaths, first arena entry, first damage, mob defeats, boss participation, ability hit rate, and player drop-off points.
- Add performance review tasks for VFX, AI, projectiles, summons, temporary parts, and network replication.
- Keep UI text and feedback localization-ready and readable on small screens.

## Mobs

Subway mobs are managed by `MobService`.

- Mobs spawn from `Workspace.MobSpawns` in the underground monster layer.
- Mobs have beginner, normal, and elite variants.
- Mobs patrol near their spawn, chase nearby players outside safe zones, and leash back instead of chasing forever.
- Mobs are intentionally slow enough for younger players to escape.
- Mobs have a leash radius and return toward their spawn area instead of chasing forever.
- Mobs show a short attack windup before contact damage lands.
- Mobs show a simple hit reaction when damaged.
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
- Bosses can spawn in the center arena or underground subway arena.
- Current boss types include Trash Titan, Junk Colossus, and Subway Horror.
- Boss health scales with server player count.
- The boss has health, chases nearby players, and attacks players outside safe zones.
- Boss attacks show a danger marker before damage lands.
- Players who contributed damage receive the prototype boss reward bundle when the boss dies.
- Current boss contribution reward: `TrashCoins` and `ScrapCores`.
- Boss contributors receive a reward popup when the boss dies.
- The boss has an overhead health bar.
- The boss also has a top-screen health UI while active.

Planned expansion:

- More boss abilities, phases, and encounter warnings.
- Better rewards and loot tables.

## Progression

Current progression is a lightweight prototype foundation.

- Core currencies: `TrashCoins`, `ScrapCores`, and `RoyalShards`.
- Players receive a simple session daily reward for testing.
- `ProgressionDefinitions` contains beginner goals, reward tuning, passive definitions, class unlock notes, spell tree notes, and loot tables.
- All classes remain available during prototype testing.
- Later versions can persist rewards and unlocks with DataStores.

## Analytics

`AnalyticsService` tracks lightweight in-server playtest counters.

- Player joins.
- Class choices.
- Ability casts.
- Ability hits and total damage.
- Player deaths and death positions.
- Debug logging can be toggled from the service.

## Current Technical Structure

- `ServerScriptService/GameManager.server.lua`: boots services.
- `ServerScriptService/MapService.lua`: generates the map, bases, safe zones, exit-protection buffers, arena, subway entrances/exits, monster layer, spawns, and remotes.
- `ServerScriptService/SafeZoneService.lua`: reusable safe-zone and exit-protection checks.
- `ServerScriptService/CombatService.lua`: server-side damage validation.
- `ServerScriptService/ClassService.lua`: player class attributes, ability lists, and starter ability tools.
- `ServerScriptService/ProgressionService.lua`: currencies and simple daily reward.
- `ServerScriptService/AnalyticsService.lua`: lightweight playtest counters.
- `ServerScriptService/MageService.lua`: compatibility alias for `ClassService`.
- `ServerScriptService/PlayerLifecycleService.lua`: home base assignment, respawn placement, respawn protection, and kill/death stats.
- `ServerScriptService/SpellService.lua`: ability casting, cooldowns, targeting behaviors, projectiles, summons, and effects.
- `ServerScriptService/AbilityService.lua`: compatibility alias for the ability service path.
- `ServerScriptService/MobService.lua`: subway mob spawning, chase, attack, and respawn.
- `ServerScriptService/BossService.lua`: timed boss spawning, boss AI, and rewards.
- `StarterPlayer/StarterPlayerScripts/SafeZoneFeedback.client.lua`: client status badge for safe-zone and PvP state.
- `StarterPlayer/StarterPlayerScripts/CombatFeedback.client.lua`: floating damage numbers, hit marker, death messages, respawn countdown display, cast flashes, cast sounds, impact pulses, impact sounds, reward popups, boss health UI, and spell cooldown feedback.
- `StarterPlayer/StarterPlayerScripts/AbilityCasting.client.lua`: compatibility placeholder; direct tool activation is disabled.
- `StarterPlayer/StarterPlayerScripts/AbilityHotbar.client.lua`: custom ability slots, keyboard/touch selection, selected-ability casting, aiming previews, and cooldown overlays.
- `StarterPlayer/StarterPlayerScripts/BossAlert.client.lua`: boss warning, spawn, and defeated banners.
- `StarterPlayer/StarterPlayerScripts/ClassSelection.client.lua`: first-time class selection and safe-zone class changing.
- `StarterPlayer/StarterPlayerScripts/OnboardingGuide.client.lua`: objective prompts and help panel.
- `ReplicatedStorage/Modules/Config.lua`: shared tuning values.
- `ReplicatedStorage/Modules/ClassDefinitions.lua`: primary class definitions.
- `ReplicatedStorage/Modules/AbilityDefinitions.lua`: primary ability definitions.
- `ReplicatedStorage/Modules/ProgressionDefinitions.lua`: economy, goals, passives, class unlock notes, spell tree notes, and loot tables.
- `ReplicatedStorage/Modules/MageDefinitions.lua`: compatibility alias for `ClassDefinitions`.
- `ReplicatedStorage/Modules/SpellDefinitions.lua`: compatibility alias for `AbilityDefinitions`.
