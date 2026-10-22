---
type: system
game: hub
owner: shared
status: planned
sources:
  - raw/2026-10-17-speed-sim-hud.webp
  - raw/2026-10-17-speed-sim-rebirth.webp
  - raw/2026-10-17-keyboard-escape-hud.webp
updated: 2026-10-17
---

# Level And Rebirth Curve

Numbers seen in the references, and the curve we start with.

## Seen
- Level 1 needs 30 XP, Level 3 needs 110 ([[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]]). Level 21 needs 9.97K ([[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]]).
- Rebirth needs Level 10, then Level 20. Gives x1 > x1.5 (+0.5 each).
- Stage 4 "recommended level 11".
- Multipliers multiply: Global x2 * Gamepass * Items * Trail * Rebirth.

## Our starting curve (tune in playtest)
- XP to next level: `floor(30 * level ^ 1.5)` (30, 85, 156 ... about 2.9K at 21).
- Gain per click: `1 * total multiplier`. Auto-train: same gain once per second.
- Rebirth required level: `10 * (rebirths + 1)`. Rebirth multiplier: `1 + 0.5 * rebirths`.
- Zone gates: stat requirement about x4 per zone.

## Build
- Numbers in `ReplicatedStorage.Shared.Config.Stats` / `Rebirth`, logic in `StatService` / `RebirthService`. See [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]].

## Related
- [[70 Imports/Ultimate Slop Hub/blueprint/Slop Blueprint|Slop Blueprint]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
