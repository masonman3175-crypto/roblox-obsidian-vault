---
type: reference
area: weapons
owner: combat
status: idea
sources:
  - raw/2026-10-16-weapon-lineup.png
updated: 2026-10-16
tags: [reference, weapon, attachments]
---

# Weapon Lineup

![[2026-10-16-weapon-lineup.png]]

## What it is
A clean render of four guns: a compact AK-style pistol with a drum mag, two pistols with weapon lights and extended mags, and a pistol with a two-tone white and green grip.

## Why we care
This is the target look for the base arsenal: realistic proportions, worn paint, attachments that change the silhouette. Pairs with [[Color Grip Pistols Key Art]] (accent colors) and [[Pink Sniper Skin]] (skins).

## Breakdown
- Realistic scale and detail, not blocky.
- Wear: chipped edges and scuffs show bare metal, so guns feel used.
- Attachments stack: under-barrel light, extended mag, drum mag, optic.
- Two-tone parts (white grip, green sleeve) prove the accent idea works on any gun.

## How we'd build it in Roblox
- **Instances:** each gun is a Model with a PrimaryPart and MeshParts per swappable piece. `Attachment` points for muzzle, under-barrel, optic, mag.
- **Attachments:** each attachment is a small Model welded to its Attachment point with `WeldConstraint` or `RigidConstraint`.
- **Stats:** attachment stats (mag size, recoil) live in a server config ModuleScript. Visual parts never decide stats.
- **Where it lives:** gun and attachment models in the folders the contract names. Logic in ModuleScripts, thin Scripts.
- **Client vs server:** server validates every shot and hit. Client does visuals only (muzzle flash, light, recoil animation).
- **Assets needed:** meshes via generate_mesh or our own, worn-metal textures via generate_material. No store weapons.
- **Perf budget:** under ~10 MeshParts per gun, reuse texture sets across guns.
- **Steps:**
  1. Pick a starter 3 (pistol, compact AK-style pistol, sniper).
  2. Build one gun with split parts and Attachment points as the pattern.
  3. Add one attachment (extended mag) end to end, including server stats.

## Open questions
- Do attachments come from progression, or are they visual only?
-a: attachemnts can fore sure be bought
## Related
- [[Color Grip Pistols Key Art]]
- [[Pink Sniper Skin]]
- [[Night Porch Firefight]] (muzzle flash as a light source)
- [[Art Direction]]
