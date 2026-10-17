---
type: reference
area: maps
owner: shared
status: idea
sources:
  - raw/2026-10-16-overcast-rowhouse-street.png
updated: 2026-10-16
tags: [reference, map, atmosphere, environment]
---

# Overcast Rowhouse Street

![[2026-10-16-overcast-rowhouse-street.png]]

## What it is
A realistic city street from ground level: brick rowhouses with stoops and iron fences, bare trees, power lines, a bus shelter, a parked car, heavy grey sky.

## Why we care
This is the world-building target: a believable, gritty, made-up neighborhood. The map belongs to GAME FLOW, so this is a shared reference. Must stay fictional (no real street names, signs, or landmarks). See [[Art Direction]].

## Breakdown
- Flat grey overcast light, no hard sun shadows. Slightly desaturated.
- Distance fades into haze, so the street feels long.
- Repeating rowhouse modules with small changes (brick color, doors, fences).
- Street clutter (poles, power lines, bus shelter, fences, trees) gives lots of cover.
- Asphalt looks damp and patched.

## How we'd build it in Roblox
- **Sky and haze:** `Atmosphere` with medium `Density`, some `Haze`, grey `Color`. Overcast `Sky` plus `Clouds` with high `Cover`.
- **Grade:** `ColorCorrectionEffect` with negative `Saturation` and a slight cool tint.
- **Buildings:** a few rowhouse modules (MeshParts) reused with color and door swaps. insert_asset or generate_mesh, delete any scripts inside.
- **Materials:** wet patched asphalt and brick via generate_material or a `MaterialVariant` in MaterialService.
- **Power lines:** `Beam` between Attachments on poles, `CurveSize0`/`CurveSize1` for sag. Cheap and looks right.
- **Where it lives:** map and Lighting are GAME FLOW. Requests go in [[06 Tasks/Next Pass]].
- **Perf budget:** StreamingEnabled on, reuse meshes, keep tree count mobile friendly.
- **Steps:**
  1. Partner: try the Atmosphere and color grade on the current map.
  2. Make one rowhouse module and repeat it down a street.
  3. Add power line Beams and fences for cover.

## Open questions
- Does this replace or extend the current [[03 Nodes/Neighborhood Map]]?

## Related
- [[Night Porch Firefight]]
- [[03 Nodes/Neighborhood Map]]
- [[Art Direction]]
