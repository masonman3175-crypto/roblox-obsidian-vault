---
type: reference
area: maps
owner: shared
status: idea
sources:
  - raw/2026-10-16-night-porch-firefight.png
updated: 2026-10-16
tags: [reference, lighting, atmosphere, vfx]
---

# Night Porch Firefight

![[2026-10-16-night-porch-firefight.png]]

## What it is
A Roblox scene at night, seen from above at an angle: brick house with a porch, chain-link fence, parked classic sedan, players firing with muzzle flashes lighting the area.

## Why we care
Most of the mood comes from lighting alone: dark scene, a few warm lights, hard shadows. The map belongs to GAME FLOW, so this is a shared reference and map changes are the partner's call. See [[Art Direction]].

## Breakdown
- Mostly dark. Light comes from a few warm porch bulbs and a streetlight.
- Long hard shadows on the brick make players pop.
- Muzzle flashes briefly light the nearby wall and ground.
- Props set the scene: fence lines, porch chair, old car with red tail lights.

## How we'd build it in Roblox
- **Lighting:** `Lighting.Technology` = Future (point light shadows), `ClockTime` around 0 to 2, low `Ambient` and `OutdoorAmbient`, low `Brightness`.
- **Warm lights:** `PointLight` or `SpotLight` with orange-white color under porch roofs, `Shadows` on. Only a few per area.
- **Muzzle flash light (COMBAT):** `PointLight` on the gun's muzzle Attachment, on for about 0.05s per shot via `task.delay`, client-side only. Flash particles from [[VFX Studio]].
- **Post:** `ColorCorrectionEffect` with a slight warm tint, low `BloomEffect` so bulbs glow.
- **Where it lives:** Lighting settings are GAME FLOW. Muzzle light is COMBAT.
- **Client vs server:** all visual. Server never reads it.
- **Perf budget:** shadow-casting lights are expensive. Cap them per area and test on mobile.
- **Steps:**
  1. Partner: try Future lighting at night on the map with a few porch lights.
  2. Cade: add the muzzle flash PointLight to one gun and playtest in the dark.

## Open questions
- Whole game at night, or rotate with an overcast day ([[Overcast Rowhouse Street]])?

## Related
- [[Overcast Rowhouse Street]]
- [[03 Nodes/Neighborhood Map]]
- [[03 Nodes/Lighting Nodes]]
- [[Art Direction]]
