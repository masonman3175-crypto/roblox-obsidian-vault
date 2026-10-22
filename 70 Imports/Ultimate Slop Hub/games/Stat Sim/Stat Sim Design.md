---
type: game
game: Stat Sim
owner: cade
status: building
place_id: 98823628319724
sources:
  - Cade's brief (2026-10-17)
updated: 2026-10-17
---

# Stat Sim Design

Working name. Rename the folder when the game has a real name.

## Pitch
A "+1 stat" simulator like the ones on the Roblox homepage: climb a giant tower, every click or second gives +1 strength, and you feel stronger right away.

## Loop
Join > click/hold to train > stat goes up > climb to the next tower zone (gated by stat) > better multiplier > rebirth for a permanent multiplier > repeat. See [[70 Imports/Ultimate Slop Hub/blueprint/Slop Blueprint|Slop Blueprint]].

## Stats and numbers
- One main stat (Strength) that also drives a Level bar, like [[70 Imports/Ultimate Slop Hub/wiki/references/Rocket Boots Speed Sim|Rocket Boots Speed Sim]]. Free gain every second plus clicks, times multipliers. Coins (from punching) buy pets.
- Multiplier breakdown shown under the bar (Floor, Rebirth, Gamepass, Pets, Boost), like [[70 Imports/Ultimate Slop Hub/wiki/references/Keyboard Escape Sim|Keyboard Escape Sim]].
- Curve: [[70 Imports/Ultimate Slop Hub/wiki/systems/Level And Rebirth Curve|Level And Rebirth Curve]].

## Zones
- Giant tower with floors labeled in studs (10 / 50 / 100 / 999 studs), like the stud walls in [[70 Imports/Ultimate Slop Hub/wiki/references/Homepage Trends Oct 2026|Homepage Trends Oct 2026]]. Each floor has a gate that opens at a Strength requirement (about x4 per floor) and gives a bigger training multiplier.
- Top bar shows floor progress 1-N with player avatars.

## Rebirth
- Needs Level 10 x (rebirths + 1). Resets Strength and level, keeps passes. Multiplier 1 + 0.5 per rebirth. Red "!" on the button when ready. Skip product (Robux, clearly labeled) keeps your level.

## Monetization
Gamepasses: 2x Strength, Auto Train, VIP. Dev products: +1 Level, scaling Strength packs (3 sizes), Rebirth Skip, 15 min x2 boost. Treadmill-style training pads in tiers later. Full list of patterns: [[70 Imports/Ultimate Slop Hub/wiki/monetization/Simulator Monetization Touchpoints|Simulator Monetization Touchpoints]]. HUD: [[70 Imports/Ultimate Slop Hub/wiki/ui/Simulator HUD Layout|Simulator HUD Layout]]. Rules in [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]].

## Studio
Place "ultimate slopp v1" (`98823628319724`). Layout per [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]]. Code mirror: `games/Stat Sim/src/`.

## What's built (v1, 2026-10-17, after Cade's feedback)
Cade's verdict on v0: keep the +1 Strength idea and the "monetization all over the screen" look; everything else needed work. v1:
- **Automatic Strength:** everyone gets 1 free click of Strength every second (Base 5 x multipliers). Clicking adds more (server rate limit 12/s). Auto Click pass = +5 free clicks/sec.
- **A reason to be strong: Punch the Dummy.** Punch lane east of spawn (`Map.Gameplay.PunchLane`). Press E at the dummy (ProximityPrompt, server decides): distance = 8 x Strength^0.4 studs, Coins = distance x your best floor's multiplier. The dummy flies down the lane on every client, landing label shows studs and Coins. Best punch saved.
- **Pets per floor:** one pet stand per floor (`Map.Gameplay.PetStands`), fixed Coin price, no random rolls (Config.Pets). Pets add to a Pets multiplier (+0.5 to +14 each) and float next to you. Floor gate required.
- **You get buff:** character scales with Strength (1.25x at 1K, 1.5x at 1M, max 2x) and WalkSpeed goes up.
- **Faster numbers:** floors need 150 / 2K / 25K / 300K / 4M Strength (x2 / x5 / x15 / x50 / x150). XP per level = 20 x level^2.
- **Buttons work in Studio:** any pass/product with Id `0` is granted for free in Studio (server checks `RunService:IsStudio()`, live servers ignore it). Shop shows "TEST".
- **Reference-style buttons:** every HUD button and panel uses `Controllers.UiStyle` (see [[70 Imports/Ultimate Slop Hub/wiki/ui/Sim Button Anatomy|Sim Button Anatomy]]): dark lip, stud texture, gloss, icon that pokes out, press animation.
- Still from v0: level bar, rebirth (Level 10 x (rebirths + 1), x1.5 per rebirth, Skip product), 6-floor tower with gates the server enforces, shop with 3 passes + 6 products, DataStore `StatSim_v1`, global board `TopStrength_v1`.
- Map: hub, training area, punch lane dressing, floor themes by the map session, see [[70 Imports/Ultimate Slop Hub/wiki/maps/Stat Sim Map|Stat Sim Map]].

## Related
- [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Next Pass|Stat Sim Next Pass]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
