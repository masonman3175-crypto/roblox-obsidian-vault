---
type: reference
game: hub
owner: shared
status: idea
sources:
  - raw/2026-10-17-keyboard-escape-hud.webp
  - raw/2026-10-17-keyboard-escape-inventory.webp
  - raw/2026-10-17-keyboard-escape-stage4.webp
  - Event popup screenshot (pasted in chat 2026-10-17, not saved to raw)
updated: 2026-10-17
tags: [reference, simulator, obby, keyboard]
---

# Keyboard Escape Sim

![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-keyboard-escape-hud.webp|2026-10-17-keyboard-escape-hud.webp]]
![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-keyboard-escape-inventory.webp|2026-10-17-keyboard-escape-inventory.webp]]
![[70 Imports/Ultimate Slop Hub/raw/2026-10-17-keyboard-escape-stage4.webp|2026-10-17-keyboard-escape-stage4.webp]]

## What it is
Probably "+1 Speed Keyboard Escape | Candy & ..." from [[70 Imports/Ultimate Slop Hub/wiki/references/Homepage Trends Oct 2026|Homepage Trends Oct 2026]] (unverified). Player (cat skin) runs over giant keyboard keys through themed stages (Stage 2 candy pink, Stage 4 chocolate).

## Why we care
The "late game" version of the HUD: many currencies, a multiplier breakdown, starter pack, events, inventory. What Stat Sim grows into.

## Breakdown
- **Core loop:** speed stat makes you faster to escape across keyboard stages. "Jump: 16/21" (meaning unverified). "Total Speed: 26.08k". Level 21 bar 6.14k/9.97k.
- **Stages:** doorway signs "Stage 4, Recommended Level: 11". Soft gate, not hard locked.
- **Multiplier breakdown** under the bar, color-coded: Global x2, Gamepass x1, Items x1, Trail x1, Rebirth x1. Players see why they're fast.
- **Currencies (top left):** gems "0+", candy corn (event), trophies.
- **Left grid (2 columns):** Rebirth (red "!" when ready), Inventory, Sounds, **FREE!** gift, Teleport, Treadmill. Collapse arrow.
- **Right column:** **OP STARTER PACK** with countdown "14:43", "ONLY 9 R$", "NEW!"; Shop; **Custom Speed** slider (68, MAX 68); Trade; **x2 Speed ONLY R$4**.
- **Bottom row:** +1 Level, +1.3k, +3.9k, +7.8k speed buttons; amounts scale with level. ">" for more.
- **Corner:** boost icons x1, calendar x3, fire x1.15. "Event In 00:45:16". Toast "Daily Streak: 1 day, +15% Speed, play on consecutive days to grow".
- **Inventory tabs:** Trails, Skins, Items, Treadmills, Chests, Merge. Trails cost trophies or Robux: Orange 50 or R$9 (x1.5 points), Blue 250 or R$19 (x1.75), Green 350 or R$29 (x2).
- **Event popup:** native "Join Event" card: "ADMIN ABUSE + UPDATE 12", Sat Oct 24 12:30 PM, **Notify Me**. Roblox experience events, set up on the Creator Dashboard (unverified details).

## How we'd build it in Roblox
- **Instances:** `Hud` with UIGridLayout left grid, TextLabels for the multiplier breakdown, `Inventory` Frame with tab buttons + ScrollingFrame, slider Frame for custom speed.
- **Services / APIs:** MarketplaceService, DataStoreService (streak date).
- **Where it lives:** StatService exposes multipliers per source, HudController renders the list. DailyService later. See [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]].
- **Client vs server:** custom speed slider only asks for a lower WalkSpeed; server clamps to the real stat.
- **Compliance check:** starter pack countdown must be a real per-player offer window saved in data, never resetting. Chests = random, must show odds. See [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]].
- **Steps:**
  1. Multiplier breakdown text from day one.
  2. Dual-price cosmetics.
  3. Daily streak + free gift.
  4. Admin abuse events after launch.

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/ui/Simulator HUD Layout|Simulator HUD Layout]]
- [[70 Imports/Ultimate Slop Hub/wiki/monetization/Simulator Monetization Touchpoints|Simulator Monetization Touchpoints]]
- [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
