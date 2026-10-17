---
type: system
owner: flow
status: building
sources:
  []
updated: 2026-10-17
---

# Current Test And Integration Backlog

Entry point: [[00 Dashboard/Game Development Hub|Game Development Hub]]. Separate **tested presentation** from planned gameplay.

## Current direction
[[Zombie Lobby And Co-op Queues]] replaces the old Play/locker/PvP flow. One Survivors team, a shared arena spawn and cooperative party-size queues. The older menu and opposite-team tests below are historical evidence, not current entry behavior.

## Recorded tests
- [[Zombie Lobby And Co-op Queues]]: fresh lobby join, actual Leave/M return, Solo deployment and exact shared pivot, waiting larger pads, pure 1/2/3/4-member dispatch tests, server validation, real board/audio/combat checks, two death cycles, 140 floor rays and isolated rollback.
- [[Main Menu And Locker]]: real PLAY deployment using existing spawns, menu return, four skins/six wraps/five previews, validation and respawn retention; session-only cosmetics.
- [[Weapon Build Archive]]: five weapon rigs/FBX roundtrips, live animated arms/ammo/reload/recoil/ADS; isolated rollback fixtures.
- [[Sprint Slide And Map Boundary]]: three chained slides, 1.45-stud camera dip and recovery, sprint 24 studs/sec, 20-second full stamina budget, wall collision and 840 boundary rays with zero gaps.
- [[Claude AK]]: collaborator reports server raycast/damage, dummy kill and hit-marker tests. Re-test with two real clients before treating full combat/score integration as complete.

- [[Crouch And Compact Map]]: six stance cycles, 1.55-stud eye drop, headroom protection, crouched ADS/fire/reload, death/menu recovery, server validation, 900 boundary rays and 242 spawn-floor samples. Broad coplanar floor pairs 12 -> 0; isolated rollback passed.
- [[Game Audio And Music]]: 14 sound assets load in Client Play; five weapon shot/reload tests, footsteps/idle, F8 mute, cancellation, remote rejection and teardown passed. Latest effects-only repair removes music entirely; fresh tests cover 12 effect assets, native W1/W3 shot integration and teardown/restart 65 -> 65 connections.
- [[Main Street Block]]: both team deployments tested at updated compact-map pads: blue (-186, 0.9, -115), red (182, 0.7, 108). Earlier spawn coordinates and wall dimensions are historical.

## Still to verify / implement
- Multiplayer loadout synchronization, authoritative ammo/reload, death/respawn and friendly-fire behavior across every weapon, not W1 alone.
- [[HUD Scores And Feed]] with a real match service, teams, valid kill credit and timer; no fake placeholder results.
- Cooperative zombie AI/waves, NPC spawn/difficulty rules, authoritative zombie kill credit and survival objectives need implementation. PvP 6v6/10v10 targets are superseded.
- Real simultaneous 2/3/4-player queue departure, disconnect during countdown and common-spawn collision/friendly-fire acceptance remain to test. Old split-team pads are disabled; preserve the current shared co-op spawn.
- HUD/mobile legibility, touch/gamepad crouch/sprint/slide and weapon controls, reduced-motion options, performance at 20 players.
- Leaderboard is session-only: server ZombieKills plus measured best deployed-life duration. No zombie kill system/persistence/rewards yet. Retired locker selections do not supply progression.
- Two simultaneous clients: verify remote crouch posture, audio falloff/listening and team presentation. Existing single-client evidence does not establish multiplayer acceptance.
- New Dynamic Lighting/LightingScenary error (missing ReplicatedStorage Lighting System) and Cloud warnings are handed to the map owner in [[06 Tasks/Next Pass]]; unrelated to the tested movement/audio changes.
- Remaining combat/bullet-hole polish and final imported W1 geometry stay tracked by [[Claude AK]]; the separate audio presentation pass is already implemented.
- Commit Studio drafts / let Team Create save before partner testing. Git source snapshots do not publish the game.

## Reusable session prompt
```text
Pull main with git pull --rebase --autostash. Read AGENTS.md, wiki/index.md,
the last five wiki/log.md entries, Game Development Hub and latest session logs.
Inspect the active Studio place and ownership contract before editing.
Use the latest live source, not historical archive installers. Keep unrelated
map/spawn/combat work unchanged. Test the requested feature, record exact results
and remaining gaps, update only flow/shared notes, log the change, pull again,
commit and push without force. Sync the actual open Obsidian vault too.
```
