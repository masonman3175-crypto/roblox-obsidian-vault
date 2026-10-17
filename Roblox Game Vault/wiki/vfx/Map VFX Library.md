---
type: vfx
area: vfx
owner: shared
status: building
sources:
  - Studio: ServerStorage.MapTools.Vfx, Workspace.Map.Vfx (hood warfare 1.2)
updated: 2026-10-16
tags: [vfx, particles, map]
---

# Map VFX Library

Environment particle effects for [[Main Street Block]]. Built as plain ParticleEmitters by Claude through the Studio MCP (Claude can't click through the [[VFX Studio]] plugin UI). Every effect is a template you can open and tune in VFX Studio.

## Where
- **Templates:** `ServerStorage.MapTools.Vfx`. Each effect is an `Attachment` with its emitters (and light). Clone it, parent to any part.
- **Placed:** `Workspace.Map.Vfx`.
- Night-only emitters carry the attribute `NightOnly`; `LightingPresets.apply()` turns them on at Night and off at Overcast.

## Effects
| Template | What | Placed |
|---|---|---|
| BarrelFire | flames + embers + smoke + warm PointLight (shadows) | 2 burn barrels, north and south rear alleys |
| TransformerSparks | hot spark spits falling with gravity + cold flash light | transformer on `Street_Pole6` |
| VentSteam | warm white steam puffing out and rising | dryer vent on the laundromat side wall |
| StreetLeaves | dead leaves tumbling east down the street | `LeafGust` at the west end |
| LampDust | glowing dust drifting under lamps (night only) | under all 13 streetlights |

Also map-wide: flies over dumpsters (`Workspace.Map.Atmosphere`), moths at streetlights (night only), falling leaves from leafy trees, and the player fog ring (`StarterPlayerScripts.MapFogClient`).

## Textures
Roblox built-ins: `rbxasset://textures/particles/fire_main.dds`, `fire_sparks_main.dds`, `smoke_main.dds`. Ours: puff `132303803762039`, leaf `77334238131141`, speck `71003493076064`.

## Ideas next
Rain + puddle ripples, sparks from bullet hits on metal, brick dust puffs on wall hits, broken streetlight flicker (needs a tiny client script), pigeons scattering. Bullet impact VFX belong with the guns, so coordinate with GAME FLOW / partner.

## Related
- [[VFX Studio]]
- [[Lighting And Atmosphere]]
- [[Map Tools]]
- [[index]]
