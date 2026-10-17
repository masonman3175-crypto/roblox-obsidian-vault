---
type: reference
area: systems
owner: shared
status: planned
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, roblox, architecture, performance]
---

# Hood Warfare 2 Roblox Build Plan

## Minimal vertical slice

Build one original district block, one polished game mode, one weapon viewmodel, and one readable HUD before expanding.

## Architecture

- `Workspace.Map` holds anchored map geometry and tagged objectives.
- `ServerStorage.MapModules` holds reusable map and route modules.
- `ServerScriptService.GameModes` owns round and objective rules.
- `ReplicatedStorage.Config` holds weapon tuning and shared contracts.
- `StarterPlayerScripts` and `StarterGui` hold camera, viewmodel, input, and HUD presentation.

## How we'd build it in Roblox

- **Services / APIs:** `StreamingEnabled`, `CollectionService`, `RunService`, `TweenService`, and validated `RemoteEvent`s.
- **Client vs server:** client handles camera, animation, HUD, and effects; server validates hits, damage, ammo, currency, objectives, and rounds.
- **Perf budget:** reusable modules, simple collision meshes, limited particles/lights, and mobile checks.
- **Tools:** [[Blender MCP]] for original meshes, [[08 AI Workflow/Studio MCP Reference]] for Studio testing, and [[VFX Studio]] for effects.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Hood Warfare 2 Blockout Workflow]]
- [[Hood Warfare 2 Game Modes]]
