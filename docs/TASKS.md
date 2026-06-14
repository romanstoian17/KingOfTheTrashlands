# King of the Trashlands Tasks

This is the living task list. Add new tasks here as they come up, and mark them complete when implemented.

Status key:

- `[ ]` Not started
- `[~]` In progress
- `[x]` Done

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
- [x] Add underground subway arena.
- [x] Add subway entrance ramp.
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
- [x] Add server-published safe-zone state for UI feedback.
- [x] Add visual safe-zone enter/exit feedback.
- [x] Add `SAFE ZONE` / `PVP ENABLED` client status badge.
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
- [ ] Add stronger custom hit sounds and impact effects.
- [ ] Add player health bars or nameplate polish.
- [ ] Add dedicated boss health UI.

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
- [ ] Add death message.
- [ ] Add respawn countdown UI.
- [ ] Add anti-spawn-camping rules outside base exits.

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
- [x] Add distinct forward-ray visuals for beam, shard, spark, and lightning abilities.
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
- [x] Implement Flame Burst.
- [x] Change Flame Burst to self-area damage.
- [x] Implement Ignite.
- [x] Implement Ice Shard.
- [x] Implement Frost Bolt.
- [x] Implement Glacier Spike.
- [x] Implement Ice Armor self-buff.
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
- [x] Add forward-ray ability preview line.
- [x] Add self-area ability radius preview.
- [x] Hide world aiming preview for self-buff abilities.
- [ ] Add spell tree data structure.
- [ ] Add first unlockable spell upgrade.

## Mobs

- [x] Spawn mobs in the subway.
- [x] Make mobs chase nearby players.
- [x] Make mobs damage nearby players.
- [x] Allow players to damage mobs.
- [x] Respawn mobs after death.
- [x] Add mob rewards.
- [x] Add mob reward feedback popup.
- [ ] Add better mob models.
- [ ] Add mob patrol points.
- [ ] Add multiple mob types.

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
- [ ] Add boss health UI.
- [ ] Add underground boss spawn option.
- [ ] Add multiple boss types.
- [ ] Add real loot/reward table.

## Project Hygiene

- [x] Add gameplay documentation.
- [x] Add living task list.
- [x] Add Studio test checklist.
- [ ] Validate project in Roblox Studio.
- [ ] Add Rojo serve instructions after local tooling is confirmed.
- [ ] Add formatting/linting setup.
