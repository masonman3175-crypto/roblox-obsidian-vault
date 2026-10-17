---
type: reference
area: maps
owner: shared
status: idea
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, fps, environment-design, gameplay-flow]
---

# Hood Warfare 2 Reference Pack

This source pack studies urban FPS readability, combat flow, weapon handling, and presentation for an original Roblox game. It is a design reference, not a request to copy maps, assets, audio, logos, or UI.

## Branches

- [[Art Direction]] — overall visual language.
- [[Night Porch Firefight]] — warm night lighting and hard-shadow contrast.
- [[Overcast Rowhouse Street]] — street cover, haze, and readable routes.
- [[Weapon Lineup]] — realistic proportions, wear, and attachment silhouettes.
- [[Color Grip Pistols Key Art]] — controlled cosmetic color accents.
- [[Pink Sniper Skin]] — complete themed weapon skin treatment.
- [[VFX Studio]] — tool reference for effects work.
- [[Blender MCP]] — reference-driven modeling workflow.
- [[08 AI Workflow/Studio MCP Reference]] — Roblox Studio bridge and testing workflow.
- [[index]] — wiki catalog.

## Design takeaways

- Build fictional districts with a readable primary road, a safer service route, and a riskier interior shortcut.
- Use varied storefronts, houses, alleys, rooftops, windows, vehicles, curbs, utility details, and clear landmark silhouettes.
- Protect spawns from immediate straight-line fire and keep narrow choke points readable.
- Treat Turf War, team deathmatch, free-for-all, capture-the-object, attack/defend, and kill-confirmed collection as separate flow targets.
- Keep exact damage, recoil, ADS, movement, spawn, and HUD values unverified until recorded gameplay confirms them.

## How we'd build it in Roblox

- **Instances:** `Model` blocks in `Workspace.Map`, `SpawnLocation` or named spawn `Part`s, `Folder`s for `Landmarks`, `Routes`, `Cover`, and `Objectives`, plus `Attachment`s for sightline debug markers.
- **Services / APIs:** `CollectionService` tags for map roles, `StreamingEnabled` for district streaming, `RunService` for debug overlays, and `TweenService` for doors and objective feedback.
- **Where it lives:** map modules in `ServerStorage.MapModules`, map geometry in `Workspace.Map`, objective rules in `ServerScriptService.GameModes`, and client HUD/viewmodel work in `StarterPlayerScripts` and `ReplicatedStorage.Client`.
- **Client vs server:** the client renders camera, viewmodel, HUD, and debug visuals; the server validates spawns, objectives, damage, ammo, and round state.
- **Tools:** use [[Blender MCP]] for original modular meshes and [[08 AI Workflow/Studio MCP Reference]] for Studio inspection. Use [[VFX Studio]] for original effects only.
- **Perf budget:** keep static geometry anchored, use simple collision meshes, limit dynamic lights and particles, and test with StreamingEnabled on mobile-quality settings.
- **Steps:**
  1. Annotate an original 80x80-stud block with primary, secondary, and tertiary routes.
  2. Place protected spawns, three landmarks, cover, and objective markers.
  3. Test sightlines, navigation, and scale in Studio before expanding.
  4. Add one polished mode and record screenshots for comparison.

## Open questions

- Exact weapon stats, movement transitions, map dimensions, spawn positions, and HUD behavior remain unverified.
- Which original district theme and game mode should receive the first polished blockout?

## Related

- [[raw/2026-10-16-hood-warfare-2-reference-pack]]
- [[index]]
