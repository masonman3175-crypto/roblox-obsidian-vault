---
type: reference
area: vfx
owner: shared
status: idea
sources:
  - raw/2026-10-16-vfx-rune-trail.png\n  - raw/2026-10-16-vfx-blender-magic-circle.webp\n  - raw/2026-10-16-vfx-gold-rune-burst.png
updated: 2026-10-16
tags: [reference, vfx, stylized]
---

# Stylized VFX References

![[2026-10-16-vfx-rune-trail.png]]
![[2026-10-16-vfx-blender-magic-circle.webp]]
![[2026-10-16-vfx-gold-rune-burst.png]]

## What it is
Showcase VFX: a trail of glowing rune symbols, Blender-made effects (lightning, a light pillar, fire, ground circles with runes, debris) and a gold rune burst with flying rocks.

## Breakdown
- Effects are layered: ground ring decal + vertical mesh (pillar, beam) + particles + debris chunks + light.
- Custom textures (runes, symbols) instead of default fire and smoke.
- Mesh-based VFX (rings, cylinders with scrolling textures) made in Blender, then animated in Roblox.
- For our game: use this layering for killstreaks (LOOKOUT, SUPPLY DROP), gun wrap showcases and kill effects. Keep it street-themed (no magic runes).

## How we'd build it in Roblox
- Mesh rings and pillars from Blender ([[Blender MCP]]) as MeshParts. Scroll the texture with a `Texture` + `OffsetStudsV` tween, or use a `Beam` with `TextureSpeed`.
- `ParticleEmitter`s with custom flipbook textures (`FlipbookLayout`) built in [[VFX Studio]].
- Debris: small parts with velocity, then `Debris:AddItem`.
- Fire with `:Emit()` bursts from client code.

## Related
- [[Map VFX Library]]
- [[VFX Studio]]
- [[index]]
