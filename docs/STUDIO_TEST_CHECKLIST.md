# Studio Test Checklist

Use this checklist when testing the current Roblox build in Studio. Mark each item as pass, fail, or blocked, and add notes for any bug we need to fix.

Status key:

- `[ ]` Not tested
- `[x]` Passed
- `[!]` Failed
- `[-]` Blocked

## Setup

- [ ] Open the project through Rojo sync or the current Studio place.
- [ ] Start a local server with at least two players when testing PvP.
- [ ] Confirm the Output window has no startup errors.
- [ ] Confirm `Workspace` contains generated folders: `Bases`, `Arena`, `Subway`, `SafeZones`, `ExitProtectionZones`, `MobSpawns`, and `BossSpawns`.

## Join And Class Selection

- [ ] Player spawns at one of the 16 outer bases.
- [ ] First-time player sees class selection before normal combat use.
- [ ] Clicking outside the class selection does not auto-select a class.
- [ ] Selecting Fire Caster grants Fireball, Flame Burst, and Ignite.
- [ ] Selecting Ice Mage grants Ice Shard, Frost Bolt, Ice Nova, Glacier Spike, Glacier Path, Hail Crash, Ice Armor, and Ice Warden.
- [ ] Selecting Lightning Mage grants Lightning Bolt, Spark Shot, and Blink Surge.
- [ ] Player can change class while inside a safe zone.
- [ ] Player cannot change class outside a safe zone.

## Hotbar And Ability Input

- [ ] Default Roblox backpack UI is hidden.
- [ ] Custom hotbar appears after selecting a class.
- [ ] Pressing `1`, `2`, or `3` selects an ability but does not cast it.
- [ ] Clicking/tapping a hotbar slot selects an ability but does not cast it.
- [ ] Selected hotbar slot has a visible selected marker.
- [ ] Left click casts the selected ability on desktop.
- [ ] World tap casts the selected ability on mobile or touch emulation.
- [ ] Ability cooldown overlay appears after a valid cast.
- [ ] Ability slot gives clear ready feedback when cooldown ends.
- [ ] Cast sound and cast flash appear after a valid cast.

## Mobile And Controller

- [ ] Touch player can select a class.
- [ ] Touch player can select an ability from the hotbar.
- [ ] Touch player can cast by tapping the world.
- [ ] Touch aiming uses the center/camera fallback when needed.
- [ ] Controller player can navigate class selection.
- [ ] Controller player can select an ability.
- [ ] Controller player can cast the selected ability.
- [ ] Hotbar buttons are large enough to read on a small screen.

## Aiming Preview

- [ ] Aimed abilities show a destination marker at the aimed point.
- [ ] Self-area abilities do not show a world targeting preview.
- [ ] Self-buff abilities do not show a world targeting preview.
- [ ] Projectile, raycast, multi-raycast, line-wave, targeted-area, and summon abilities show a destination marker.
- [ ] Preview does not block raycasts or movement.
- [ ] Preview disappears or updates correctly after class changes.

## Safe Zones And PvP

- [ ] Safe-zone UI shows `SAFE ZONE` while inside a base.
- [ ] Recently respawned player sees `EXIT PROTECTION` in their home base or base exit buffer.
- [ ] Safe-zone UI shows `PVP ENABLED` outside bases.
- [ ] Player inside a base cannot damage another player.
- [ ] Player outside a base cannot damage a target inside a base.
- [ ] Exit-protected player cannot damage another player.
- [ ] Exit-protected player cannot be damaged by another player.
- [ ] Exit protection clears after moving beyond the home base exit buffer.
- [ ] Players outside bases can damage each other in the central arena.
- [ ] Respawn-protected players cannot deal damage.
- [ ] Respawn-protected players cannot receive damage.

## Combat Feedback

- [ ] Validated damage shows floating damage numbers.
- [ ] Fireball is large and easy to read while flying.
- [ ] Ice Shard fires three readable shards in a small spread.
- [ ] Low-health warning appears when the local player is badly hurt.
- [ ] Attacker sees hit marker after damaging a target.
- [ ] Impact pulse appears on damaged targets.
- [ ] Impact sound plays for nearby validated damage.
- [ ] No combat feedback appears for blocked safe-zone damage.
- [ ] Attacker sees blocked-damage feedback when safe-zone rules prevent damage.

## Mobs

- [ ] Subway arena is reachable from the central arena.
- [ ] Both central arena subway entrance pads teleport the player underground.
- [ ] Both underground exit pads teleport the player back to the central arena.
- [ ] Underground monster layer has enough visible floor space to fight mobs.
- [ ] Subway mobs spawn at underground spawn points.
- [ ] Mobs chase nearby players outside safe zones.
- [ ] Mobs move slowly enough for young players to escape.
- [ ] Mobs return toward their spawn area instead of chasing forever.
- [ ] Mobs show attack windup before damage lands.
- [ ] Mobs damage nearby players outside safe zones.
- [ ] Mobs do not chase players into bases.
- [ ] Player abilities damage mobs.
- [ ] Ice Warden can attack nearby mobs outside safe zones.
- [ ] Mobs respawn after death.
- [ ] Mob contributors receive `TrashCoins` after mob death.

## Boss

- [ ] Boss warning appears before the first boss spawn.
- [ ] Boss spawns in the center arena.
- [ ] Boss has an overhead health bar.
- [ ] Player abilities damage the boss.
- [ ] Boss attacks nearby players outside safe zones.
- [ ] Boss does not damage players inside bases.
- [ ] Boss contributors receive `TrashCoins` after boss death.
- [ ] Boss defeated banner appears after death.

## Respawn And Stats

- [ ] Player death increments `Deaths`.
- [ ] PvP kill credit increments attacker's `Kills`.
- [ ] Death message appears after player death.
- [ ] Death message includes killer/source details when available.
- [ ] Respawn countdown display appears after player death.
- [ ] Player respawns at assigned home base.
- [ ] Ability cooldowns reset after respawn.
- [ ] `TrashCoins` exists in `leaderstats`.

## Notes

- Date:
- Tester:
- Studio version:
- Known issues:

## Performance

- [ ] Test with at least two players using abilities at the same time.
- [ ] Test several Ice Warden summons over time.
- [ ] Test subway mobs while abilities are being cast.
- [ ] Confirm temporary VFX parts disappear after their effect.
- [ ] Confirm no obvious frame drops on a lower-end device or emulator.
- [ ] Confirm Output has no repeated warnings/errors during combat.
