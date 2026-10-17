---
type: system
owner: flow
status: building
sources:
  []
updated: 2026-10-17
---

# Game Development Hub

> Start here for the current co-op zombie direction, not the old PvP/menu or keyboard demo. Place: **hood warfare 1.2**, `127865723083651`. This is a notes/source archive, not a published Roblox place.

## Latest shipped pass (2026-10-17)
- [[Lobby Movement And Queue Circles]] — lobby sprint/slide, V first/third person, eight independent glowing circles (two per mode), floating counts/15-second timers and no top banner.
- [[Zombie Lobby And Co-op Queues]] — physical compact-map lobby, session leaderboard, 1/2/3/4-player co-op queues, one Survivors team and one shared gameplay spawn. Old Play/locker menu removed; zombie AI/waves are next work.
- [[Crouch And Compact Map]] — C / Left Ctrl / B crouch with camera drop; sprint+C/B still slides. Speed 8; tested eye drop 1.55 studs.
- [[Game Audio And Music]] — weapon, movement and UI sounds; effects restored independently; **no background music**.
- [[Main Street Block]] — tighter building-edge perimeter (26.6% less enclosed area), floor overlap repair and repaired floors inside the compact boundary; old split-team pads are now disabled by the co-op lobby.

## Playable presentation
- [[Zombie Lobby And Co-op Queues]] — join directly into the physical lobby; queue together, deploy to the shared map, M returns to the hub.
- [[Main Menu And Locker]] — retired historical menu/locker archive, no longer active.
- [[Gameplay HUD]] — handwritten gameplay overlay and its implementation branches.
- [[HUD Minimap]] — circular map and teammate markers.
- [[HUD Ammo And Weapon Display]] — real weapon/ammo display, shortcuts and crosshair.
- [[HUD Scores And Feed]] — server-data wiring and remaining integration.
- [[Sprint Slide And Map Boundary]] — sprint, repeatable slides, camera dip/shake, stamina and perimeter walls.
- [[Weapon Build Archive]] — five Blender guns, source rigs, animation files, import/polish evidence and earlier prototypes.
- [[Claude AK]] — collaborator's newer W1 firing/damage work; read this before relying on older weapon snapshots.

## World and references
- [[Main Street Block]], [[Main Street Routes and Cover]], [[Map Asset Registry]].
- [[Lighting And Atmosphere]], [[Graffiti Style]], [[Map VFX Library]].
- [[Hood Warfare 2 Reference Pack]] and its smaller linked map/mode/combat/UI branches.
- [[Weapon Lineup]], [[First Person Gun Feel]], [[Color Grip Pistols Key Art]], [[Pink Sniper Skin]].
- [[wiki/index|Full Wiki Index]] — all references, tools and implementation notes.

## Source and evidence
- [[04 Scripts/Lobby Movement And Queue Circles/Implementation|Latest lobby movement, camera and eight-circle source + tests + rollback]].
- [[04 Scripts/Zombie Lobby And Co-op Queues/Implementation|Current co-op lobby source, scene, exact tests and rollback]].
- [[04 Scripts/Audio Effects Restore/Implementation|Latest effects-only audio source + tests + rollback]] — no background music.
- [[04 Scripts/Crouch And Compact Map/Implementation|Latest crouch, compact-map and floor source + tests + rollback]].
- [[04 Scripts/Game Audio And Music/Implementation|Audio source + asset IDs + tests + rollback]] — historical 25% snapshot; current effects-only repair removes music entirely.
- [[04 Scripts/Ground And Team Spawns/Implementation|Ground/team-spawn baseline + tests]] — original pad positions are historical; latest compact-map pass supersedes them.
- [[04 Scripts/Main Menu Source/Implementation|Historical menu source + tests]] — retired, do not reinstall over current lobby.
- [[04 Scripts/Gameplay HUD Source/Implementation|HUD source]].
- [[04 Scripts/Movement And Boundary Source/Implementation|Movement/boundary source + tests]].
- [[04 Scripts/Current Runtime Snapshot/Implementation|Read-only runtime snapshot]] — includes collaborator integration; not an installer.
- [[05 Assets/Weapon Build Archive/Implementation|Blender + FBX archive]].
- [[07 Archive/Prototype Weapons/Archive Guide|Earlier prototype archive]] — historical only.
- [[08 AI Workflow/Session Logs/2026-10-17-codex|Latest Codex session history]], [[08 AI Workflow/Session Logs/2026-10-16-codex|Earlier Codex history]], [[08 AI Workflow/Session Logs/2026-10-16-claude|Claude session history]].

## Next, not already shipped
- [[Current Test And Integration Backlog]] — multiplayer, match state, combat wiring, two-client audio checks, persistence and mobile work.
- [[01 Game Design/O Blah Warfare Design|Design Doc]] now records the co-op zombie pivot. Historical 6v6/10v10 PvP targets are superseded; NPC waves, kill credit and survival rules remain next work.
- [[Obsidian Vault Sync]] — where these notes live and how to avoid opening the stale mirror again.

## Latest movement/hold repair — 2026-10-17
- [[Slide Animation And Two-Handed Hold]]: procedural slide pose + real ground-transition fix, floor clearance and two-hand weapon support.
- [[Third Person Combat]] remains the camera direction: third only, no V toggle.
- [[04 Scripts/Slide Animation And Two-Handed Hold/VERIFICATION.txt]] contains exact tests and rollback. Commit Studio drafts before partner acceptance.
