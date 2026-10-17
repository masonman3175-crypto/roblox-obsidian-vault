---
type: reference
area: weapons
owner: combat
status: idea
sources:
  - raw/2026-10-16-color-grip-pistols-keyart.webp
updated: 2026-10-16
tags: [reference, weapon, cosmetic, thumbnail]
---

# Color Grip Pistols Key Art

![[2026-10-16-color-grip-pistols-keyart.webp]]

## What it is
Key art from another Roblox game (Gang Wars). Five hands holding black pistols, each with one bright accent color (green, blue, red) on the grip, mag, or weapon light.

## Why we care
- One accent color on a black gun is cheap to make and easy to recognize. Good cosmetic slot.
- The layout (hands coming in from every edge toward the center) is a strong thumbnail or icon idea.

## Breakdown
- Base guns are matte black. Accent parts are saturated, slightly glossy plastic.
- Weapon lights glow in the accent color, so it reads in the dark.
- Extended and drum mags make each gun's silhouette different.
- **Don't copy:** their branding, the cash pile, or anything gang themed. Our content rules ban gang names and hand signs.

## How we'd build it in Roblox
- **Instances:** split each pistol into MeshParts: `Body`, `Grip`, `Mag`, `Light`. Accent = `Color` on `Grip`/`Mag` with a plastic material, or a SurfaceAppearance with AlphaMode Overlay so part Color shows through (unverified, test first).
- **Light glow:** a `SpotLight` on an Attachment at the front of `Light`, matching the accent color. Client-side only.
- **Where it lives:** accent color list in the cosmetics config module. Folders per contract.
- **Client vs server:** server stores owned colors and sets them on the gun. Lights are client visuals.
- **Assets needed:** pistol mesh split into those parts (generate_mesh or our own). No store weapons.
- **Thumbnail:** pose R15 hands holding our guns in a Studio scene, shot from above, with our own props.
- **Perf budget:** SpotLights only on the local player's gun and nearby players.
- **Steps:**
  1. Split the pistol mesh into Body, Grip, Mag, Light.
  2. Add 4 to 6 accent colors to the cosmetics config.
  3. Mock a thumbnail with our guns using this layout.

## Open questions
- Should accent colors also tint muzzle flash or tracers?

## Related
- [[Weapon Lineup]]
- [[Pink Sniper Skin]]
- [[Art Direction]]
