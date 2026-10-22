---
type: game
game: hub
owner: shared
status: building
sources:
  - Cade's brief (2026-10-17)
updated: 2026-10-17
---

# Slop Blueprint

The recipe for a homepage-style Roblox game. Every new game in `games/` starts from this. Goal: a playable, saving, monetized loop in one or two sessions, then polish from player data.

## The loop (stat simulator version)
1. **Join** and you are leveling within 3 seconds. No menus in the way.
2. **Gain** +1 stat per click / per second / per step. A big number goes up and a popup says so.
3. **Spend or unlock**: stats gate the next zone (taller part of the tower, harder obby stage, better training spot).
4. **New zone** = bigger multiplier, new look, a reason to keep going.
5. **Rebirth**: reset stats for a permanent multiplier. Repeat with everything faster.
6. **Monetization at every step** (see [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]]): 2x stats, auto-train, VIP, boosts, skips.

## Must-have systems (build order)
1. Stats + leaderstats + DataStore saving (see [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]])
2. Training (click / hold / walk-to-gain), server-side with a rate limit
3. Zones gated by stat requirements (tower floors or obby stages)
4. Rebirth with multipliers
5. Shop UI: gamepasses + dev products, IDs in one config module
6. Global leaderboard (OrderedDataStore) + in-server leaderstats
7. Juice: number popups, sounds, particles on level-up
8. Later: pets/eggs (needs visible odds), daily rewards, codes, group reward, quests

## Numbers that feel good
- First gain is instant and visible. First zone unlock inside 1-2 minutes.
- Zone requirements grow about x3 to x5 per zone. Multipliers grow about x1.5 to x2.
- Rebirth cost grows each time; rebirth multiplier stacks (+50% or +1x per rebirth).
- Format big numbers: 1.2K, 3.4M, 5.6B.

## Done = shippable v0
- Loop works start to rebirth in Studio playtest.
- Data saves and loads (tested by leave and rejoin).
- Every purchase path calls the real Roblox prompt and is granted server-side (ProcessReceipt).
- Vault has the game's Design.md, devlog entry, session log, all pushed.

## Related
- [[70 Imports/Ultimate Slop Hub/blueprint/Monetization And Compliance|Monetization And Compliance]]
- [[70 Imports/Ultimate Slop Hub/blueprint/Studio Layout|Studio Layout]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
