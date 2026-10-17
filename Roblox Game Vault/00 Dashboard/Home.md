---
title: Roblox Game Vault
game: hood warfare 1.2
place_id: 127865723083651
status: active
---

# Roblox Game Vault

This is the working brain for the Roblox place **hood warfare 1.2** (moved from o blah warfare 1.1 on 2026-10-16).

## Start here
- **[[00 Dashboard/Game Development Hub|OPEN THE CURRENT GAME HUB]]** — menu, HUD, guns, animations, movement, walls, references and tests.
- [[01 Game Design/Game Overview]]
- [[02 Systems/Keyboard System]]
- [[03 Nodes/Full Game Tree]]
- [[04 Scripts/KeyBoardSystem]]
- [[06 Tasks/Next Pass]]
- [[01 Game Design/O Blah Warfare Design]]
- [[08 AI Workflow/AI Workflow Overview]]
- [[wiki/index|Wiki Index]] (references, tools, devlog)
- [[wiki/Art Direction|Art Direction]]

## Rule of thumb
Roblox Studio contains the playable game. This vault contains the plans, explanations, decisions, bugs, assets, and tasks that help us build it.

## Current snapshot (2026-10-16)
- Place ID: `127865723083651` (old 1.1 place: `80506494260443`)
- Game: urban FPS (see [[01 Game Design/O Blah Warfare Design]]). The keyboard keycap demo notes are from the old 1.1 place.
- Original assignment: Cade + Claude on map assets, partner + Codex on guns. Later user requests added menu/HUD/movement; [[Claude AK]] records newer collaborator server combat. See the current hub rather than treating the initial assets-only snapshot as current.
- **Map:** [[wiki/maps/Main Street Block|Main Street Block]] in `Workspace.Map`, about 3,170 parts, 0 scripts.
  - Look: [[wiki/maps/Lighting And Atmosphere|Lighting And Atmosphere]] (Night preset active), [[wiki/maps/Graffiti Style|Graffiti Style]]
  - Gameplay read: [[wiki/maps/Main Street Routes and Cover|Main Street Routes and Cover]]
  - Assets + credits: [[wiki/maps/Map Asset Registry|Map Asset Registry]]
- **Tools:** [[wiki/tools/Map Tools|Map Tools]], [[wiki/tools/Studio MCP Gotchas|Studio MCP Gotchas]], [[wiki/tools/Store Asset Vetting|Store Asset Vetting]], [[wiki/tools/Graffiti Generator|Graffiti Generator]], [[wiki/tools/Blender MCP|Blender MCP]]
- **To do by hand:** set `Lighting.Technology` to Future in Studio.
