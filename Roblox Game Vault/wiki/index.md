---
type: index
owner: shared
updated: 2026-10-17
---

# Wiki Index

Catalog of every wiki page. AI reads this first and updates it on every ingest. Format: `- [[Page]] - summary (status)`.
Rules: see the Wiki schema section in `CLAUDE.md` / `AGENTS.md`. Timeline: [[log]].

## Overview
- [[00 Dashboard/Game Development Hub|Game Development Hub]] - current shooter navigation, source bundles and pending work (building)
- [[Art Direction]] - the look: gritty made-up city, realistic guns, color cosmetics (idea)

## UI
- [[Gameplay HUD]] - handwritten HUD and reference breakdown (building)
- [[HUD Minimap]] - circular 605-proxy map and teammate markers (building)
- [[HUD Ammo And Weapon Display]] - ammo, silhouettes, slot controls and reticle (building)
- [[HUD Scores And Feed]] - score/timer/event data contract and integration gaps (building)
- [[Custom Shop UI]] - themed shop panel structure (cards, prices, currency) to reskin in our style (idea)
- [[Main Menu And Locker]] - retired historical menu/locker implementation; replaced by co-op lobby (dropped)
- [[Hood Warfare 2 HUD and Presentation]] - HUD, feedback, input, and presentation study list (idea)

## VFX
- [[Stylized VFX References]] - layered mesh + particle + debris VFX for killstreaks and wraps (idea)
- [[Map VFX Library]] - map particle effects: burn barrels, sparks, vent steam, leaves, lamp dust, flies, moths, player fog (building)

## Maps
- [[Main Street Block]] - hood warfare 1.2 map: street, rowhouses, alleys, landmarks, grime, real oaks + old cars, decal graffiti (building)
- [[Graffiti Style]] - real spray-paint look, tag name list, 13 original pieces in game, layered over tag walls (building)
- [[Lighting And Atmosphere]] - Overcast + Night presets (switchable module), sodium streetlights, porch lights, alley lights, lit windows (building)
- [[Main Street Routes and Cover]] - lanes, landmarks, cover inventory, spawn/zone suggestions for GAME FLOW (idea)
- [[Map Asset Registry]] - every store/AI/uploaded asset id in the map, rejected assets, Workspace.Map folder counts (building)
- [[Hood Warfare 2 Reference Pack]] - original FPS reference pack: urban routes, modes, combat questions, and blockout plan (idea)
- [[Hood Warfare 2 Urban Routes]] - primary, service, and interior route layers for readable urban combat (idea)
- [[Hood Warfare 2 Blockout Workflow]] - small-block-first map building and testing sequence (planned)
- [[Night Porch Firefight]] - night lighting: warm porch lights, hard shadows, muzzle flash light (idea)
- [[Overcast Rowhouse Street]] - overcast haze, brick rowhouses, power lines, street cover (idea)

## Systems
- [[Lobby Movement And Queue Circles]] - lobby sprint/slide, V camera toggle, eight independent circular queues and no title banner (shipped)
- [[Zombie Lobby And Co-op Queues]] - compact co-op lobby, leaderboard, two circles per 1/2/3/4-player mode and shared spawn (shipped)
- [[Crouch And Compact Map]] - crouch/camera stance, tighter perimeter and floor repair; music later removed (shipped)
- [[Game Audio And Music]] - restored weapon/movement/UI effects, no background music, with isolated rollback (shipped)
- [[Current Test And Integration Backlog]] - verified work, multiplayer gaps and reusable session prompt (building)
- [[Sprint Slide And Map Boundary]] - chainable slides, lower camera, longer sprint stamina and continuous perimeter walls (building)
- [[Hood Warfare 2 Game Modes]] - six original mode patterns to prototype separately (idea)
- [[Hood Warfare 2 Combat Tuning]] - verified-vs-unverified combat variables and server authority (idea)
- [[Hood Warfare 2 Roblox Build Plan]] - Roblox folders, services, ownership, and performance slice (planned)

## Weapons
- [[Claude AK]] - Blender AKM replacing Walnut AK (W1): own flash, smoke, shells, tracers, impacts, recoil climb, server-checked damage (building)
- [[Claude Beretta]] - M9 in the Silver 9mm slot (W3): posed gloved hands, slide/trigger/mag parts, fire flash, screen fuzz, dynamic crosshair, reload sound, server damage (shipped)
- [[First Person Gun Feel]] - viewmodel placement, muzzle, impacts, third-person hold (idea)
- [[Neon Sniper Skin And HUD]] - glowing gradient skin + loadout slots + kill popup (idea)
- [[Weapon Lineup]] - realistic guns, worn paint, swappable attachments (idea)
- [[Color Grip Pistols Key Art]] - one accent color per gun as a cosmetic, thumbnail layout (idea)
- [[Pink Sniper Skin]] - full themed skin on a stock sniper (idea)

## Tools
- [[Obsidian Vault Sync]] - actual open vault, Git routine and local-note recovery (building)
- [[Weapon Build Archive]] - Blender models/rigs/FBXs, import/polish sources and historical evidence (building)
- [[VFX Studio]] - free all-in-one VFX plugin for Studio, features still to verify (planned)
- [[Blender MCP]] - AI drives Blender: model from raw/ refs, viewport screenshots (building, tested 2026-10-16)
- [[08 AI Workflow/Studio MCP Reference]] - Roblox Studio MCP setup and tools (tested 2026-10-16)
- [[Map Tools]] - ServerStorage.MapTools: RowhouseKit, WallOverlay, LightingPresets, prop + graffiti templates, lighting backup (building)
- [[Studio MCP Gotchas]] - pivots, decal vs image ids, light culling, rate limits, Play-mode limits (building)
- [[Store Asset Vetting]] - hidden-script backdoors found in free cars + checklist for every store asset (building)
- [[Graffiti Generator]] - HTML canvas tool that made our 13 graffiti pieces, how to make more (building)

## Raw, not ingested yet
- `raw/2026-10-16-weapon-kit-reference.png` - Roblox Weapons kit docs thumbnails (AK, shotgun, pistol) (added by partner)
- `raw/2026-10-16-fps-reference.png` - FPS gameplay screenshot, first-person AK in a street (added by partner) (used as scale ref for [[Main Street Block]])
- `raw/2026-10-16-youtube-fps-reference.md` - YouTube FPS gameplay link for weapon feel (added by partner)

## Devlog
- [[2026-10-17]] - co-op zombie lobby/queues, one team/shared spawn, effects-only audio, crouch and compact-map fixes (shipped)
- [[2026-10-16]] - vault turned into an LLM wiki, refs ingested, map passes 1-4, graffiti, lighting + night variant

## Older notes (not migrated yet)
- [[00 Dashboard/Home]] - vault home and place snapshot
- [[01 Game Design/O Blah Warfare Design]] - main design doc
- [[01 Game Design/Game Overview]] - game overview
- [[02 Systems/Keyboard System]] - keyboard keycap mechanic
- [[03 Nodes/Full Game Tree]] - Studio Explorer tree
- [[03 Nodes/Neighborhood Map]] - OUTDATED: old OBlockRivals map in the 1.1 place, replaced by [[Main Street Block]]
- [[03 Nodes/Lighting Nodes]] - lighting setup
- [[03 Nodes/Workspace Nodes]] - Workspace contents
- [[04 Scripts/KeyBoardSystem]] - keyboard script notes
- [[05 Assets/Audio Assets]] - audio list
- [[06 Tasks/Next Pass]] - task list and cross-side requests
- [[08 AI Workflow/AI Workflow Overview]] - how we use AI
- [[08 AI Workflow/Two Dev Rules]] - ownership rules
- [[08 AI Workflow/Studio MCP Reference]] - Studio MCP tools
