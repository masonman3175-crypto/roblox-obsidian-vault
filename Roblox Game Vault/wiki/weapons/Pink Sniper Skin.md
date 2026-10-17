---
type: reference
area: weapons
owner: combat
status: idea
sources:
  - raw/2026-10-16-pink-sniper-skin.png
updated: 2026-10-16
tags: [reference, weapon, skin, cosmetic]
---

# Pink Sniper Skin

![[2026-10-16-pink-sniper-skin.png]]

## What it is
A cosmetic skin for a bolt-action sniper from Sniper Duels: pastel pink camo body, long black suppressor with small heart and lace decals, black scope.

## Why we care
It shows how much a skin can change a stock gun with only a recolor and a few decals. That fits our cosmetic-only monetization. See [[Art Direction]].

## Breakdown
- Base gun keeps the same shape. Only color, pattern, and decals change.
- Contrast: soft pink body against black metal parts (scope, suppressor, trigger) keeps the gun readable.
- Small themed details (hearts, lace trim) sell the theme without clutter.
- Glossy, slightly metallic finish with light edge wear.

## How we'd build it in Roblox
- **Instances:** gun is a Model of MeshParts. Paintable parts (body, stock) get a `SurfaceAppearance` per skin. Black parts (scope, suppressor) stay untouched so every skin keeps the same silhouette.
- **Decals:** bake hearts and trim into the skin's ColorMap texture instead of separate Decals (fewer instances, no z-fighting).
- **Swapping skins:** keep each skin as a SurfaceAppearance (or a folder of them) in ReplicatedStorage and clone it onto the gun. Setting SurfaceAppearance texture maps from a script at runtime may not be allowed (unverified), so clone whole instances.
- **Where it lives:** skin list in the same config module as the product placeholder IDs. Folders per `ServerStorage.README_CONTRACT`.
- **Client vs server:** server owns which skins a player has and applies them. Skins never change stats.
- **Assets needed:** one UV-unwrapped sniper mesh (generate_mesh or our own, no store weapons) and PBR textures per skin.
- **Tools:** texture work happens outside Studio. [[VFX Studio]] not needed.
- **Perf budget:** 1024px maps max per skin, reuse normal and roughness maps across skins.
- **Steps:**
  1. Model one sniper with clean UVs and separate paintable parts.
  2. Make a default skin and one themed skin like this one.
  3. Build the skin config and a server-side "apply skin" function.

## Open questions
- Skins per gun, or skins that fit every gun (needs a shared UV layout)?

## Related
- [[Weapon Lineup]]
- [[Color Grip Pistols Key Art]]
- [[Art Direction]]
