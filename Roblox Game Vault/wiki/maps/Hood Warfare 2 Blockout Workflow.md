---
type: reference
area: maps
owner: shared
status: planned
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, maps, blockout, testing]
---

# Hood Warfare 2 Blockout Workflow

## Build order

1. Annotate an original overhead layout.
2. Place protected spawns, three landmarks, cover, and objective markers.
3. Build one detailed 80x80-stud block.
4. Test scale, navigation, sightlines, and performance.
5. Capture overhead and street-level screenshots before expanding.

## How we'd build it in Roblox

- **Instances:** anchored `Model`s, `SpawnLocation`s, `Attachment`s for sightline markers, and `Folder`s for objectives.
- **Services / APIs:** `RunService` for debug overlays and `CollectionService` for tagged map roles.
- **Where it lives:** blockout in `Workspace.Map`; debug code in `ServerScriptService.Debug` and `StarterPlayerScripts.DebugClient`.
- **Client vs server:** client visualizes debug data; server validates spawn and objective positions.
- **Perf budget:** simple collisions, anchored static geometry, limited dynamic lights, and mobile playtests.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Hood Warfare 2 Urban Routes]]
- [[08 AI Workflow/Studio MCP Reference]]
