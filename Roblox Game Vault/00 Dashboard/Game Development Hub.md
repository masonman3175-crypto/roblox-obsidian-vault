---
type: system
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# Game Development Hub

> Start here for the current shooter, not the old keyboard demo. Place: **hood warfare 1.2**, `127865723083651`. This is a notes/source archive, not a published Roblox place.

## Playable presentation
- [[Main Menu And Locker]] — detailed menu, aerial live-map background, PLAY, character/weapon previews, four session skins and six wraps.
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
- [[04 Scripts/Main Menu Source/Implementation|Menu source + tests]].
- [[04 Scripts/Gameplay HUD Source/Implementation|HUD source]].
- [[04 Scripts/Movement And Boundary Source/Implementation|Movement/boundary source + tests]].
- [[04 Scripts/Current Runtime Snapshot/Implementation|Read-only runtime snapshot]] — includes collaborator integration; not an installer.
- [[05 Assets/Weapon Build Archive/Implementation|Blender + FBX archive]].
- [[07 Archive/Prototype Weapons/Archive Guide|Earlier prototype archive]] — historical only.
- [[08 AI Workflow/Session Logs/2026-10-16-codex|Codex session history]], [[08 AI Workflow/Session Logs/2026-10-16-claude|Claude session history]].

## Next, not already shipped
- [[Current Test And Integration Backlog]] — multiplayer, match state, combat wiring, audio, persistence and mobile work.
- [[01 Game Design/O Blah Warfare Design|Design Doc]] still says 6v6; the later user map request was about **10v10 / 20 players**. Resolve the target before round implementation; do not silently change spawns.
- [[Obsidian Vault Sync]] — where these notes live and how to avoid opening the stale mirror again.
