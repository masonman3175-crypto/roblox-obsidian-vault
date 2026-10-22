---
type: ui
game: hub
owner: shared
status: planned
sources:
  - raw/2026-10-17-speed-sim-hud.webp
  - raw/2026-10-17-keyboard-escape-hud.webp
updated: 2026-10-17
---

# Simulator HUD Layout

Standard homepage-sim HUD from [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]] and [[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]]. Both use nearly the same layout. Copy the layout, make our own art.

```
+---------------------------------------------------------------+
| [cur1][cur2]        (1)--(2)--(3)...(12) progress track        |
|                     "Quest: Collect 3 Trophies [0/3]"          |
| [Rebirth][Inv ]                                 [ Quests   ]   |
| [Trails ][FREE]                                 [ Shop     ]   |
| [Auras  ][Tele]                                 [x2 ONLY R$]   |
|                                                 [ settings ]   |
|      x2 (Global)  x1 (Gamepass)   Total: 26.0K   x1 (Rebirth)  |
|      [=========== Level 21 ============   6.1K / 9.9K ]        |
|      [+1 Level] [+1.3K] [+3.9K] [+7.8K] [>]                    |
+---------------------------------------------------------------+
```

## Rules
- Big chunky square buttons, icon + outlined label, bright gradients, thick dark UIStroke.
- Left = progression (rebirth, cosmetics, free stuff). Right = money (shop, x2, starter pack). Bottom = the number going up.
- Red "!" badge on Rebirth when ready.
- Popups ("+42" with icon) float near center on every gain.
- Mobile: UIScale / UIAspectRatioConstraint; keep bottom-left (thumbstick) and bottom-right (jump) clear.

## Build
- `StarterGui.Hud` ScreenGui, `IgnoreGuiInset` true. Frames `Left`, `Right`, `Bottom`, `Top`, wired by `HudController`. See [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]].

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/monetization/Simulator Monetization Touchpoints|Simulator Monetization Touchpoints]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
