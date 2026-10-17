---
type: reference
area: weapons
owner: combat
status: idea
sources:
  - raw/2026-10-16-skin-neon-sniper-hud.png
updated: 2026-10-16
tags: [reference, weapon, skin, hud]
---

# Neon Sniper Skin And HUD

![[2026-10-16-skin-neon-sniper-hud.png]]

## What it is
First-person sniper with a "Miami Nights" skin: hot pink, yellow and blue gradient with a glow, plus a clean loadout bar (3 slots with gun icons and ammo) and a "+100 XP / KILLED / LONGSHOT" kill popup.

## Breakdown
- The skin is a bright gradient texture plus a slight emissive glow. It pops even in dim light.
- HUD slots show a thumbnail of the actual skin, not just a name. The selected slot is highlighted.
- The kill popup is small, top right, with a bonus tag (LONGSHOT).

## How we'd build it in Roblox
- **Skin:** `SurfaceAppearance` per skin (ColorMap + emissive-looking bright map); glow via a faint `Highlight` or a Neon trim part. Same system as [[Pink Sniper Skin]].
- **HUD:** `ScreenGui` with `ViewportFrame` thumbnails per slot. The kill popup is a `TextLabel` tweened in with `TweenService`.
- **Where:** cosmetics config module + COMBAT HUD client. Skins are cosmetic only.

## Related
- [[Pink Sniper Skin]]
- [[Color Grip Pistols Key Art]]
- [[index]]
