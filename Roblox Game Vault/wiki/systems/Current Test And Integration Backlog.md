---
type: system
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# Current Test And Integration Backlog

Entry point: [[00 Dashboard/Game Development Hub|Game Development Hub]]. Separate **tested presentation** from planned gameplay.

## Recorded tests
- [[Main Menu And Locker]]: real PLAY deployment using existing spawns, menu return, four skins/six wraps/five previews, validation and respawn retention; session-only cosmetics.
- [[Weapon Build Archive]]: five weapon rigs/FBX roundtrips, live animated arms/ammo/reload/recoil/ADS; isolated rollback fixtures.
- [[Sprint Slide And Map Boundary]]: three chained slides, 1.45-stud camera dip and recovery, sprint 24 studs/sec, 20-second full stamina budget, wall collision and 840 boundary rays with zero gaps.
- [[Claude AK]]: collaborator reports server raycast/damage, dummy kill and hit-marker tests. Re-test with two real clients before treating full combat/score integration as complete.

## Still to verify / implement
- Multiplayer loadout synchronization, authoritative ammo/reload, death/respawn and friendly-fire behavior across every weapon, not W1 alone.
- [[HUD Scores And Feed]] with a real match service, teams, valid kill credit and timer; no fake placeholder results.
- Target capacity: later user request 10v10 (~20 players), older design 6v6. Resolve before changing team/round/spawn rules.
- No new spawn placements were requested. Preserve original transforms unless the user explicitly asks otherwise.
- HUD/mobile legibility, touch/gamepad sprint/slide and weapon controls, reduced-motion options, performance at 20 players.
- Persistent skins/wraps, XP/currency/shop and monetization are not supplied by session-only locker selections.
- Audio/reload/bullet-hole polish and final imported W1 geometry remain tracked by [[Claude AK]].
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
