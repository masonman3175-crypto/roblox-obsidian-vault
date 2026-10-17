---
type: reference
area: maps
owner: shared
status: idea
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, maps, routes]
---

# Hood Warfare 2 Urban Routes

## Core idea

Use three readable route layers: a primary road, a safer service route, and a risky interior shortcut.

## Details

- Vary storefront widths, house setbacks, alleys, rooftops, windows, vehicles, curbs, and utility details.
- Give three landmarks distinct silhouettes so players can orient without a minimap.
- Keep walkways clear and protect spawns from immediate straight-line fire.
- Mark exact geometry and named locations as `(unverified)` until footage confirms them.

## How we'd build it in Roblox

- **Instances:** `Model`s in `Workspace.Map`, folders for `Routes`, `Landmarks`, `Cover`, and named spawn `Part`s.
- **Services / APIs:** `CollectionService` route tags and `StreamingEnabled` for district streaming.
- **Where it lives:** geometry in `Workspace.Map`; route metadata in `ServerStorage.MapModules`.
- **Client vs server:** client draws optional route debug lines; server owns spawn and objective validation.
- **Steps:** block one 80x80-stud district, test three route choices, then expand only after a sightline pass.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Night Porch Firefight]]
- [[Overcast Rowhouse Street]]
