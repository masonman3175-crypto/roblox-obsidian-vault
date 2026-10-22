---
type: monetization
game: hub
owner: shared
status: planned
sources:
  - raw/2026-10-17-speed-sim-hud.webp
  - raw/2026-10-17-speed-sim-buy-prompt.webp
  - raw/2026-10-17-speed-sim-rebirth.webp
  - raw/2026-10-17-speed-sim-treadmills.webp
  - raw/2026-10-17-keyboard-escape-hud.webp
  - raw/2026-10-17-keyboard-escape-inventory.webp
updated: 2026-10-17
---

# Simulator Monetization Touchpoints

Every place the reference sims ask for Robux, with prices seen. Rules: [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]].

| Touchpoint | Type | Seen price | Where |
|---|---|---|---|
| x2 Multiplier / x2 Speed | gamepass (unverified) | R$3, R$4 | right side, rainbow button |
| OP Starter Pack | limited offer | R$9 | right top, countdown |
| +1 Level | dev product | not shown | bottom row |
| +speed buttons (scale with level) | dev products | not shown | bottom row |
| Rebirth Skip ("Lose nothing!") | dev product | not shown | rebirth panel |
| Treadmill tiers x3 to x99 | gamepasses | R$79, 149, 249, 499, 1399 | treadmill room |
| Trails x1.5 to x2 | Robux or soft currency | R$9/19/29 or 50/250/350 trophies | inventory |
| Chests | random | not shown | inventory (needs odds) |
| Auras, Skins | cosmetic + boost | not shown | left buttons |
| Admin abuse events | free, drives players | n/a | Roblox events, Notify Me |

## Patterns
- **Price anchor:** tiny R$3-9 first buy right on screen.
- **Ladder:** same item in 5-6 tiers, each flashier.
- **Scaling products:** buy-stat buttons grow with level so they stay useful.
- **Dual price:** cosmetics cost grind or Robux.
- **Pay to skip pain:** rebirth skip keeps level.

## Compliance notes for us
- Show the real price from `GetProductInfo`.
- Starter pack countdown: real per-player window saved in data, no reset on rejoin.
- Chests: show % odds of every item before buying.

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]]
- [[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
