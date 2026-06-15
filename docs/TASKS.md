# King of the Trashlands Tasks

This is the living task list. Add new tasks here as they come up, and mark them complete when implemented.

Status key:

- `[ ]` Not started
- `[~]` In progress
- `[x]` Done

## Implementation Order

Use this section to decide what to build next. The detailed category backlog below remains the full checklist.

### Phase 1 - Make The Current Build Testable And Comfortable

- [ ] Validate project in Roblox Studio.
- [x] Add Studio playtest checklist sections for mobile and controller.
- [x] Add performance test checklist for low-end devices.
- [x] Add playtest notes template for testers.
- [x] Implement full class switching flow.
- [x] Add server-side class switch cooldown.
- [x] Clear old temporary buffs when switching class.
- [x] Destroy old class summons when switching class.
- [x] Reset ability cooldowns when switching class.
- [x] Ensure every current class is available for now.
- [x] Make mobs slower and easier for young players to escape.
- [x] Add mob leash radius so mobs return to their spawn area.
- [x] Add mob attack windup so players can react.
- [x] Add blocked-damage feedback when safe zones prevent a hit.
- [x] Add clear ability-ready feedback when cooldown ends.

### Phase 2 - Make Combat Easier And More Fun For Kids

- [x] Add kid-friendly combat tuning pass so abilities are easier to hit with.
- [x] Make Fireball visually and mechanically bigger while keeping balanced damage.
- [x] Change Ice Shard into a multi-shard cast with total damage similar to the current single shard.
- [x] Widen narrow raycast/projectile abilities where needed.
- [x] Review all area, wave, and summon abilities for friendly hit reliability.
- [x] Add per-ability difficulty rating for aiming and kid-friendly tuning.
- [x] Add per-ability device notes for mouse, touch, and controller.
- [x] Make ability special effects feel cool, impressive, and readable.
- [x] Add richer projectile, area, summon, and impact VFX.
- [x] Add stronger cast animations or motion beats for major abilities.
- [x] Add low-health warning feedback.
- [x] Add target hit readability pass for mobile screens.

### Phase 3 - Make The World Easier To Understand

- [x] Add simple objective prompts after class selection.
- [x] Add first-session tutorial prompts for class selection, safe zones, arena, subway, and boss.
- [ ] Add a short practice area or training dummy inside/near bases.
- [x] Add clear signs, arrows, lights, or paths from bases to the center arena.
- [x] Add clear signs, arrows, lights, or paths from the center arena to subway entrances.
- [x] Add a first-time arrow/path from player base to central arena.
- [x] Add a first-time arrow/path from central arena to subway entrance.
- [x] Add visual landmarks so players can quickly understand where they are.
- [ ] Add boss spawn map indicator.
- [ ] Add minimap or simple world direction indicators for base, arena, subway, and boss.
- [x] Add a help panel that explains controls, safe zones, class switching, and rewards.

### Phase 4 - Rebuild The Map Into A City

- [x] Rebuild the city map layout around a large central fighting space.
- [x] Add buildings and structures around the central arena.
- [ ] Redesign how the 16 bases are located around the city.
- [ ] Explore better base placement than the current simple outer ring.
- [x] Keep the current outer base ring if no better layout is ready yet.
- [x] Add underground boss spawn option.

### Phase 5 - Expand Classes And Abilities

- [x] Design 7 additional available classes.
- [x] Add definitions for 7 additional classes.
- [x] Design at least 8 abilities for each class.
- [x] Document each new ability's behavior, damage, cooldown, range, visuals, and animation idea.
- [x] Add ability category tags for projectile, area, summon, movement, defense, and utility.
- [x] Add class role tags such as easy, tanky, mobile, ranged, support, and builder.
- [x] Implement ability definitions for the new classes.
- [x] Add placeholder visuals and animations for the new class abilities.
- [ ] Add class preview/demo moments in class selection.
- [ ] Add class switch confirmation when changing away from the current class.

### Phase 6 - Improve Enemies And Bosses

- [x] Add mob hit reaction and clear attack animation.
- [x] Add easier beginner mob type.
- [x] Add better mob models.
- [x] Add mob patrol points.
- [x] Add multiple mob types.
- [x] Add stronger elite mob type for later subway depth.
- [x] Add boss attack windups and telegraphs.
- [x] Add boss arena danger markers before large attacks.
- [x] Add boss participation reward rules that are clear and fair.
- [x] Add boss scaling by server player count.
- [x] Add multiple boss types.

### Phase 7 - Progression, Economy, And Retention

- [x] Define core currencies: common, uncommon, and rare.
- [x] Add reward tuning table for mobs, bosses, PvP, quests, and daily play.
- [x] Add beginner goals that reward trying arena, subway, and boss content.
- [x] Add simple daily reward or first-win bonus.
- [x] Add economy balance spreadsheet or data table.
- [x] Add anti-grind tuning review so rewards feel good without becoming too fast.
- [x] Add passive ability framework later.
- [x] Add class unlock framework later, while keeping all classes available for now.
- [x] Add spell tree data structure.
- [x] Add first unlockable spell upgrade.
- [x] Add real loot/reward table.

### Phase 8 - Analytics, Performance, And Polish

- [x] Add lightweight server analytics counters for class choice, deaths, kills, mob defeats, boss participation, and class switching.
- [ ] Add funnel events for join, class selected, first arena entry, first damage dealt, first death, first mob defeated, and first boss encounter.
- [x] Track ability hit rate, average damage, and casts per ability during tests.
- [x] Track where players die most often.
- [ ] Track if players fail to find the subway or boss.
- [x] Add combat balance debug logging that can be toggled off.
- [x] Add VFX performance budget for particles, lights, tweens, and temporary parts.
- [ ] Pool or throttle short-lived effect parts if performance drops.
- [ ] Add shared VFX helper module if ability effects keep growing.
- [ ] Add shared AI helper module if mobs, bosses, and summons duplicate logic.
- [ ] Add network ownership and replication review for projectiles, summons, mobs, and bosses.
- [ ] Add server performance profiling pass.
- [ ] Add client performance profiling pass.
- [ ] Add mobile-first ability button sizing review.
- [ ] Add controller/gamepad navigation review for class selection and hotbar.
- [ ] Add readable UI text sizing pass for small screens.
- [ ] Add colorblind/readability pass for safe, danger, class, and ability colors.
- [ ] Add localization-ready text keys for UI strings.
- [ ] Add simple settings for music, SFX, camera shake, and visual intensity.
- [ ] Add stronger custom hit sounds and impact effects.
- [ ] Add player health bars or nameplate polish.
- [ ] Add basic camera shake only for major abilities, with an option to reduce it.
- [ ] Add automated tests for safe-zone damage rules.
- [ ] Add formatting/linting setup.
- [ ] Add script organization review after class count grows.

## Foundation

- [x] Create Rojo project structure.
- [x] Add runtime-generated test map.
- [x] Add 16 player bases around the outside of the map.
- [x] Add base spawn points.
- [x] Add base labels.
- [x] Add safe-zone volumes for all bases.
- [x] Add central PvP arena.
- [x] Add visual boundary markers for the arena.
- [x] Add simple arena obstacles and cover.
- [x] Rebuild the city map layout around a large central fighting space.
- [x] Add buildings and structures around the central arena.
- [ ] Redesign how the 16 bases are located around the city.
- [ ] Explore better base placement than the current simple outer ring.
- [x] Keep the current outer base ring if no better layout is ready yet.
- [x] Add clear signs, arrows, lights, or paths from bases to the center arena.
- [x] Add clear signs, arrows, lights, or paths from the center arena to subway entrances.
- [ ] Add minimap or simple world direction indicators for base, arena, subway, and boss.
- [x] Add visual landmarks so players can quickly understand where they are.
- [x] Add underground subway arena.
- [x] Add subway entrance ramp.
- [x] Add two clear subway entrance teleport pads.
- [x] Add two underground return exit teleport pads.
- [x] Expand underground layer for monsters.
- [x] Add mob spawn points.
- [x] Add boss spawn point.

## Safe Zones And Combat

- [x] Create reusable `SafeZoneService`.
- [x] Create server-side `CombatService`.
- [x] Ignore PvP spell damage when attacker is inside a safe zone.
- [x] Ignore PvP spell damage when target is inside a safe zone.
- [x] Ignore PvP spell damage when attacker has respawn protection.
- [x] Ignore PvP spell damage when target has respawn protection.
- [x] Ignore mob and boss damage when target player is inside a safe zone.
- [x] Ignore mob and boss damage when target player has respawn protection.
- [x] Make mobs and bosses avoid targeting players inside safe zones.
- [x] Add base exit-protection volumes.
- [x] Add server-side exit-protection validation.
- [x] Ignore PvP damage when attacker has exit protection.
- [x] Ignore PvP damage when target has exit protection.
- [x] Ignore mob and boss damage when target player has exit protection.
- [x] Make mobs and bosses avoid targeting players with exit protection.
- [x] Add server-published safe-zone state for UI feedback.
- [x] Add visual safe-zone enter/exit feedback.
- [x] Add `SAFE ZONE` / `PVP ENABLED` client status badge.
- [x] Add `EXIT PROTECTION` client status badge.
- [x] Add Studio test checklist for safe-zone damage rules.
- [ ] Add automated tests for safe-zone damage rules.

## Combat Feedback

- [x] Add server-published combat feedback after validated damage.
- [x] Add floating damage numbers.
- [x] Add attacker hit marker.
- [x] Add spell cooldown feedback.
- [x] Add overhead mob health bars.
- [x] Add overhead boss health bar.
- [x] Add basic ability cast sounds.
- [x] Add basic local cast flash feedback.
- [x] Add basic hit impact sounds.
- [x] Add basic hit impact pulse effects.
- [x] Add dedicated boss health UI.
- [ ] Add stronger custom hit sounds and impact effects.
- [x] Make ability special effects feel cool, impressive, and readable.
- [x] Add stronger cast animations or motion beats for major abilities.
- [x] Add richer projectile, area, summon, and impact VFX.
- [ ] Add player health bars or nameplate polish.
- [x] Add low-health warning feedback.
- [x] Add clear ability-ready feedback when cooldown ends.
- [x] Add blocked-damage feedback when safe zones prevent a hit.
- [x] Add target hit readability pass for mobile screens.
- [x] Add VFX performance budget for particles, lights, tweens, and temporary parts.
- [ ] Pool or throttle short-lived effect parts if performance drops.

## Onboarding And UX

- [x] Add first-session tutorial prompts for class selection, safe zones, arena, subway, and boss.
- [ ] Add a short practice area or training dummy inside/near bases.
- [x] Add simple objective prompts after class selection.
- [x] Add a first-time arrow/path from player base to central arena.
- [x] Add a first-time arrow/path from central arena to subway entrance.
- [x] Add a help panel that explains controls, safe zones, class switching, and rewards.
- [ ] Add mobile-first ability button sizing review.
- [ ] Add controller/gamepad navigation review for class selection and hotbar.
- [ ] Add readable UI text sizing pass for small screens.
- [ ] Add colorblind/readability pass for safe, danger, class, and ability colors.
- [ ] Add localization-ready text keys for UI strings.
- [ ] Add simple settings for music, SFX, camera shake, and visual intensity.

## Player Lifecycle

- [x] Create `PlayerLifecycleService`.
- [x] Assign each player a home base.
- [x] Set each player's respawn location to their home base.
- [x] Move spawned characters to their assigned home base.
- [x] Reset player spell cooldowns on death and respawn.
- [x] Add short respawn protection.
- [x] Prevent respawn-protected players from dealing damage.
- [x] Prevent respawn-protected players from receiving damage.
- [x] Add player death stat.
- [x] Add player kill stat.
- [x] Add recent attacker kill credit for PvP deaths.
- [x] Add death message.
- [x] Add respawn countdown UI.
- [x] Add anti-spawn-camping rules outside base exits.

## Classes And Abilities

- [x] Add mage definitions.
- [x] Add spell definitions.
- [x] Add class definition alias for future non-mage fighters.
- [x] Add ability definition alias for future non-spell abilities.
- [x] Promote `ClassDefinitions` to primary class data.
- [x] Promote `AbilityDefinitions` to primary ability data.
- [x] Add `ClassService` as primary class service.
- [x] Keep `MageService` as compatibility alias.
- [x] Replace class selection client script with `ClassSelection.client.lua`.
- [x] Add `SelectClass` and `ClassSelectionStatus` remotes.
- [x] Keep old mage/spell remotes and attributes as compatibility aliases.
- [x] Add server ability service alias for future code.
- [x] Add ability metadata fields: `AbilityType`, `Targeting`, `Effects`, and `Tags`.
- [x] Add data-driven ability visual metadata.
- [x] Add reusable `Raycast` ability behavior.
- [x] Add reusable `MultiRaycast` ability behavior.
- [x] Add reusable `ProjectileExplode` ability behavior.
- [x] Add reusable `DelayedSelfArea` ability behavior.
- [x] Add reusable `LineWave` ability behavior.
- [x] Add reusable `TargetedArea` ability behavior.
- [x] Add reusable `Summon` ability behavior.
- [x] Add distinct raycast visuals for beam, shard, spark, and lightning abilities.
- [x] Add distinct area visuals for self-area abilities.
- [x] Add distinct aura visuals for self-buff abilities.
- [x] Add `SelfArea` ability targeting behavior.
- [x] Add `SelfBuff` ability targeting behavior.
- [x] Add configurable active spell slot count.
- [x] Add configurable active ability slot count.
- [x] Add three starting mage classes: Fire Caster, Ice Mage, and Lightning Mage.
- [x] Add server-validated mage selection.
- [x] Add first-time mage selection UI.
- [x] Simplify class selection UI to icon-first cards.
- [x] Add safe-zone-only mage changing.
- [x] Add mage selection status feedback.
- [x] Add class selection remote fallback for older synced places.
- [x] Give players a replicated spell list.
- [x] Give players a replicated ability list.
- [x] Give players starter ability tools after selecting a class.
- [x] Add `CastAbility` remote and service path.
- [x] Add client pointer/camera aim for ability casting.
- [x] Add mobile/controller camera-center aim fallback.
- [x] Keep server-side range clamp and damage validation for aimed abilities.
- [x] Validate casts against the player's active spell list.
- [x] Validate casts against the player's active ability list.
- [x] Implement Fireball.
- [x] Change Fireball to projectile explosion.
- [x] Implement Flame Burst.
- [x] Change Flame Burst to self-area damage.
- [x] Implement Ignite.
- [x] Implement Ice Shard.
- [x] Implement Frost Bolt.
- [x] Change Frost Bolt to projectile explosion.
- [x] Implement Ice Nova delayed spreading self-area.
- [x] Implement Glacier Path forward line wave.
- [x] Implement Hail Crash targeted area.
- [x] Implement Glacier Spike.
- [x] Implement Ice Armor self-buff.
- [x] Implement Ice Warden summon.
- [x] Implement Lightning Bolt.
- [x] Implement Spark Shot.
- [x] Implement Storm Lance.
- [x] Implement Blink Surge speed self-buff.
- [x] Enforce server-side spell cooldowns.
- [x] Route spell damage through server combat validation.
- [x] Add ability hotbar UI.
- [x] Add keyboard selection for ability slots.
- [x] Add tap/click selection for mobile and mouse hotbar slots.
- [x] Add left-click activation for the selected ability.
- [x] Add world-tap activation for the selected ability on mobile.
- [x] Disable direct tool activation so selection does not instantly cast.
- [x] Hide default Roblox backpack UI.
- [x] Add cooldown overlays on ability slots.
- [x] Add client-side aiming preview.
- [x] Replace forward-ray preview line with destination marker.
- [x] Hide world aiming preview for self-area abilities.
- [x] Hide world aiming preview for self-buff abilities.
- [x] Implement full class switching flow.
- [x] Add server-side class switch cooldown.
- [x] Clear old temporary buffs when switching class.
- [x] Destroy old class summons when switching class.
- [x] Reset ability cooldowns when switching class.
- [x] Ensure every current class is available for now.
- [x] Add kid-friendly combat tuning pass so abilities are easier to hit with.
- [x] Make Fireball visually and mechanically bigger while keeping balanced damage.
- [x] Change Ice Shard into a multi-shard cast with total damage similar to the current single shard.
- [x] Widen narrow raycast/projectile abilities where needed.
- [x] Review all area, wave, and summon abilities for friendly hit reliability.
- [x] Design 7 additional available classes.
- [x] Add definitions for 7 additional classes.
- [x] Design at least 8 abilities for each class.
- [x] Document each new ability's behavior, damage, cooldown, range, visuals, and animation idea.
- [x] Implement ability definitions for the new classes.
- [x] Add placeholder visuals and animations for the new class abilities.
- [x] Add per-ability difficulty rating for aiming and kid-friendly tuning.
- [x] Add per-ability device notes for mouse, touch, and controller.
- [ ] Add basic camera shake only for major abilities, with an option to reduce it.
- [x] Add ability category tags for projectile, area, summon, movement, defense, and utility.
- [x] Add class role tags such as easy, tanky, mobile, ranged, support, and builder.
- [ ] Add class preview/demo moments in class selection.
- [ ] Add class switch confirmation when changing away from the current class.
- [x] Add spell tree data structure.
- [x] Add first unlockable spell upgrade.

## Progression And Economy

- [x] Define core currencies: common, uncommon, and rare.
- [x] Add reward tuning table for mobs, bosses, PvP, quests, and daily play.
- [x] Add simple daily reward or first-win bonus.
- [x] Add beginner goals that reward trying arena, subway, and boss content.
- [x] Add passive ability framework later.
- [x] Add class unlock framework later, while keeping all classes available for now.
- [x] Add economy balance spreadsheet or data table.
- [x] Add anti-grind tuning review so rewards feel good without becoming too fast.

## Mobs

- [x] Spawn mobs in the subway.
- [x] Make mobs chase nearby players.
- [x] Make mobs damage nearby players.
- [x] Allow players to damage mobs.
- [x] Respawn mobs after death.
- [x] Add mob rewards.
- [x] Add mob reward feedback popup.
- [x] Make mobs slower and easier for young players to escape.
- [x] Add mob leash radius so mobs return to their spawn area.
- [x] Add mob attack windup so players can react.
- [x] Add mob hit reaction and clear attack animation.
- [x] Add easier beginner mob type.
- [x] Add stronger elite mob type for later subway depth.
- [x] Add better mob models.
- [x] Add mob patrol points.
- [x] Add multiple mob types.

## Boss

- [x] Add boss spawn service.
- [x] Spawn first boss after a short test delay.
- [x] Spawn later bosses every random 5-10 minutes.
- [x] Add configurable boss warning timer.
- [x] Add boss spawn warning.
- [x] Add boss spawned banner.
- [x] Add boss defeated banner.
- [x] Give boss health.
- [x] Allow players to damage boss.
- [x] Make boss attack nearby players.
- [x] Prevent boss damage against players inside safe zones.
- [x] Reward boss contributors with placeholder currency.
- [x] Publish boss health updates to clients.
- [x] Add boss health UI.
- [x] Add underground boss spawn option.
- [x] Add multiple boss types.
- [x] Add boss attack windups and telegraphs.
- [x] Add boss arena danger markers before large attacks.
- [ ] Add boss spawn map indicator.
- [x] Add boss participation reward rules that are clear and fair.
- [x] Add boss scaling by server player count.
- [x] Add real loot/reward table.

## Analytics And Playtesting

- [x] Add lightweight server analytics counters for class choice, deaths, kills, mob defeats, boss participation, and class switching.
- [ ] Add funnel events for join, class selected, first arena entry, first damage dealt, first death, first mob defeated, and first boss encounter.
- [x] Add combat balance debug logging that can be toggled off.
- [x] Track ability hit rate, average damage, and casts per ability during tests.
- [x] Track where players die most often.
- [ ] Track if players fail to find the subway or boss.
- [x] Add Studio playtest checklist sections for mobile and controller.
- [x] Add performance test checklist for low-end devices.
- [x] Add playtest notes template for testers.

## Project Hygiene

- [x] Add gameplay documentation.
- [x] Add living task list.
- [x] Add Studio test checklist.
- [ ] Validate project in Roblox Studio.
- [x] Add Rojo serve instructions.
- [ ] Add formatting/linting setup.
- [ ] Add script organization review after class count grows.
- [ ] Add shared VFX helper module if ability effects keep growing.
- [ ] Add shared AI helper module if mobs, bosses, and summons duplicate logic.
- [ ] Add server performance profiling pass.
- [ ] Add client performance profiling pass.
- [ ] Add network ownership and replication review for projectiles, summons, mobs, and bosses.
