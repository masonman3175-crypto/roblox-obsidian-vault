---
type: reference
game: hub
owner: shared
status: idea
sources:
  - raw/2026-10-17-speed-sim-hud.webp
  - raw/2026-10-17-speed-sim-buy-prompt.webp
  - raw/2026-10-17-speed-sim-rebirth.webp
  - raw/2026-10-17-speed-sim-treadmills.webp
updated: 2026-10-17
tags: [reference, simulator, speed, rebirth]
---

# Rocket Boots Speed Sim

![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-speed-sim-hud.webp|2026-10-17-speed-sim-hud.webp]]
![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-speed-sim-buy-prompt.webp|2026-10-17-speed-sim-buy-prompt.webp]]
![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-speed-sim-rebirth.webp|2026-10-17-speed-sim-rebirth.webp]]
![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-speed-sim-treadmills.webp|2026-10-17-speed-sim-treadmills.webp]]

## What it is
A speed simulator Cade played (name not visible in the shots). "SPAM TO USE ROCKETBOOTS!" across a long lane with trophies on the floor.

## Why we care
Cleanest example of the level + rebirth + buy-level loop. Almost a 1:1 template for Stat Sim.

## Breakdown
- **Core loop:** spam click/tap to use rocket boots and move down a lane. Moving fills a level bar ("Level 1 26/30", "Level 3 74/110"). Trophies on the floor give +1 / +2 / +6 (soft currency).
- **Zones:** sign "Forest - 35m" with a big up arrow, zones by distance. Top bar is a **1-12 checkpoint track** with player and friend avatar bubbles showing where everyone is.
- **Quests:** banner "Collect 3 Trophies! [0/3]" under the top bar, Quests button on the right.
- **Rebirth panel:**
  - Speed x1 > x1.5 (+0.5 per rebirth).
  - Level 10 > Level 20 (required level grows each rebirth).
  - "Rebirth will reset your level", progress bar 3/10.
  - Buttons: **Rebirth!** and **Skip** (green gem, "Lose nothing!") = paid rebirth with no reset (price not shown).
- **HUD:** left column Rebirth / Trails / Auras (big square icon buttons). Right: Quests, **"x2 Multiplier ONLY R$3?!"** rainbow button, settings gear. Bottom: two multiplier chips (lightning x1, rebirth x1), level bar, then **+1 Level** (red), **50K Speed** (green), **250K Speed** (blue), **1M Speed** (purple), **+** (more).
- **Buy prompt:** native Roblox "Buy item: x2 Multiplier! R$3". Real prompt, real price.
- **Treadmills room:** row of treadmills, each a steps multiplier, flashier VFX as price rises:

| Treadmill | Boost | Cost |
|---|---|---|
| Circuit | x2 Steps | 3 rebirths (icon) |
| VIP | x3 | R$79 |
| VIP+ | x7 | R$149 |
| Matrix | hidden | R$249 |
| Inferno | x30 | R$499 |
| Admin | x99 | R$1399 |

## How we'd build it in Roblox
- **Instances:** ScreenGui `Hud` (Left/Right/Bottom Frames, UIListLayout, UIGradient rainbow on x2), `RebirthPanel` Frame, BillboardGui price tags over treadmills, Touched pads.
- **Services / APIs:** MarketplaceService (PromptGamePassPurchase, PromptProductPurchase, ProcessReceipt), DataStoreService, TweenService for bar fill.
- **Where it lives:** StatService (XP, level), RebirthService, TrainingService (treadmill multiplier while on pad), MonetizationService. See [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]].
- **Client vs server:** client fires `Train` on click; server adds XP with multipliers and a rate limit. Treadmill bonus checked server-side (on pad + owns it).
- **Compliance check:** shown prices from `GetProductInfo`. Skip button clearly says Robux. See [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]].
- **Steps:**
  1. Level bar + XP from clicks.
  2. Rebirth panel with x1.5 and growing level requirement.
  3. Buy-level / buy-stat buttons as dev products.
  4. Treadmill tiers: one free unlocked by rebirths, rest gamepasses.

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/systems/Level And Rebirth Curve|Level And Rebirth Curve]]
- [[70 Imports/Ultimate Slop Hub/wiki/ui/Simulator HUD Layout|Simulator HUD Layout]]
- [[70 Imports/Ultimate Slop Hub/wiki/monetization/Simulator Monetization Touchpoints|Simulator Monetization Touchpoints]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
