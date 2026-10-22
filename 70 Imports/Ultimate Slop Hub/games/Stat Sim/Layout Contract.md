---
type: game
game: Stat Sim
owner: cade
status: building
sources:
  - Cade's feedback round 2 (2026-10-17)
updated: 2026-10-17
---

# Stat Sim Layout Contract (v2)

Every session building in place 98823628319724 follows this. The gameplay session (the one that wrote this) owns all scripts and everything in `Workspace.Map.Gameplay`. Art sessions dress AROUND the anchors.

## Golden rules
- Never move, resize, rename or delete anything inside `Workspace.Map.Gameplay` (except: you MAY recolor/re-material the plain `Ground` parts of worlds, and you MAY add decor next to anchors, not inside them).
- Never edit scripts, ReplicatedStorage (except `ReplicatedStorage.PetModels` for the pet session), StarterGui, StarterPlayer, ServerScriptService. Never start a playtest (only the gameplay session playtests; if Edit tools fail with "not available in Play mode", wait 2 min and retry).
- Delete every script inside inserted store assets and list them. Follow wiki/tools/Store Asset Vetting.md and wiki/tools/Studio MCP Gotchas.md (build in chunks, task.wait between).
- Look: cartoony, saturated, "dopamine" Roblox sim style. Reference: YouTube "Make Your Roblox Game Look 10x Better With Lighting" (Developer, vkEXLmRAQgs): deep blue saturated sky, puffy clouds, strong bloom + sun rays, stud-textured ground, bright pastel-saturated colors, soft shadows, nothing blinding white.
- No z-fighting: never put two coplanar surfaces at the same height (offset tiles by at least 0.05 studs or use one part).

## Coordinates (baseplate 2048x2048, top y=0)
| Thing | Where | Notes |
|---|---|---|
| SpawnLocation | (0, 0.5, 0) facing +X | First thing a new player sees is the dummy straight ahead |
| PunchLane.PunchSpot | (22, 0.5, 0) | red neon pad where you stand |
| PunchLane.Dummy | (34, ~4, 0) facing -X | ProximityPrompt E |
| Punch track | x 40 to 6040, centerline z = 0, ground top y = 0 | 6 biomes, 1000 studs each (see below) |
| Track camera corridor | x 40-6040, z 0 to +45, y 0-90 | the follow camera flies here: nothing taller than y=8 in this box |
| Track flight corridor | x 40-6040, z -8 to +8, y 0-70 | dummy flies here: keep empty |
| Hub area | everything on the baseplate except x > 40 with -60 < z < 60 | |
| Gym pads | GymPad1..6 at x = -45, -63, -81, -99, -117, -135; z = 55; 14x14 | tiers 1-6, dress as gym equipment around each pad, pad top must stay walkable |
| Hub egg stands | EggStand_Starter (-25,1,-30), EggStand_Buff (-45,1,-30), EggStand_Mega (-65,1,-30) | 8x8 pedestals; egg model + odds board spawned by code above each |
| Portals | Portal2..5 at x = -100, -70, -40, -10; z = -80 | 10x10 neon pads; dress each with a big themed archway (Candy, Frost, Lava, Space) |
| World k (2..5) | center (0, 0, -1600 - (k-2)*1200): W2 z=-1600 Candy, W3 z=-2800 Frost, W4 z=-4000 Lava, W5 z=-5200 Space | each has Ground (400x400, top y=0), WorldSpawn (center + (0,0.5,40)), ReturnPortal (center + (0,0.5,80)), two egg stands at center + (-20,1,-30) and (+20,1,-30). Gameplay counts you "in world k" within 260 studs of the center |

## Punch track biomes (x ranges, z from -60 to +60)
| # | Biome | x range | Distance it means |
|---|---|---|---|
| 1 | Grass Fields | 40-1040 | 10-100 ft |
| 2 | Desert | 1040-2040 | 100-1K ft |
| 3 | Snow Mountains | 2040-3040 | 1K-10K ft |
| 4 | Volcano | 3040-4040 | 10K-100K ft |
| 5 | Candy Land | 4040-5040 | 100K-1M ft |
| 6 | Outer Space / Moon | 5040-6040 | 1M ft+ |

Each biome: own ground (top y=0, continuous track, no gaps), a big entrance arch at its start x with the name (arch must leave the flight + camera corridors open), side scenery, and distance boards every 250 studs reading the matching feet value (log scale: board at x shows 10^(1 + (x-40)/1000) ft, e.g. x=1040 "100 FT", x=2040 "1K FT", x=3040 "10K FT").

## Code-owned (do not build)
Dummy, egg models + odds boards, pet followers, gym pad labels, portal labels, all UI.
