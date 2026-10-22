---
type: map
game: Stat Sim
owner: cade
status: building
sources:
  - Studio place 98823628319724 (ultimate slopp v1)
  - games/Stat Sim/Layout Contract.md (v2)
updated: 2026-10-17
---

# Stat Sim Map

Map art for [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Design|Stat Sim Design]], v2 layout from [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Layout Contract|Stat Sim Layout Contract]]. Cartoony "dopamine" sim look (see [[70 Imports/Ultimate Slop Hub/wiki/references/Homepage Trends Oct 2026|Homepage Trends Oct 2026]]). Props only, no scripts, everything anchored. v1 (flat plaza, tower dressing, ServerStorage pets) was deleted on 2026-10-17 after Cade's feedback.

## Do not touch
`Workspace.Map.Gameplay` anchors (PunchSpot, Dummy, GymPads, EggStands, Portals, Worlds.World2..5 Ground/WorldSpawn/ReturnPortal/egg stands). The punch track box (x > 40, |z| < 60) belongs to the track session. Nothing of ours sits in it.

## Ground and no z-fighting
- One ground surface: `Workspace.Baseplate`, recolored lime (86,180,64), SmoothPlastic, with a stud `Texture` (image `rbxassetid://7447638591` from decal 7447638611, 2 studs per tile, 55% transparent). The old stacked grass plate is gone.
- Every floor on top is a separate height: arena discs at 0.4 / 0.5 / 0.6 / 0.7, plazas at 0.3, tiles at 0.38, paths each 0.02 higher than the last so crossings never share a plane.

## Hub (`Workspace.Map.Hub`)
| Folder | Where | What |
|---|---|---|
| `PunchArena` | discs centered (6,0,0), r 30 | dark/purple/blue arena floor, yellow neon stripe spawn to dummy, 5-tier colored stands both sides (x -14..38, z +-32..56) with back walls, flags, 4 warm spotlight towers, giant boxing gloves on pillars at (36,+-22), blank jumbotron behind spawn at x=-30 |
| `Gym` | x -29..-151, z 42..89 | lilac rubber floor, walls with neon trim, giant gold dumbbell on the roof. Per pad: neon glow frame, colored backdrop with tier stars, equipment at z=74: T1 bench + dumbbells, T2 squat rack, T3 golden dumbbell rack, T4 VIP neon bench + velvet rope, T5 mega machine (weight stack, pulleys, screen, bolts), T6 admin throne gym (gold dais, throne, crown, rainbow neon mega barbell) |
| `EggPlaza` | x -80..-10, z -48..-14 | cream checker floor, ring bases per stand. Mega: red carpet, 4 gold pillars with gems, gold arch, crown at y 25, sparkles + light. Space above stands left open for the egg + odds board |
| `PortalPlaza` | x -117..7, z -99..-65 | arches over Portal2..5: Candy (striped pillars, lollipop, gumdrops), Frost (ice pillars, snow cap, icicles, crystals), Lava (basalt, fire, rocks), Space (navy/purple, ringed planet, stars) |
| `RaisedPlaza` | x -125..-75, z -5..35, top y=4.4 | brick terrace with stairs east and south, planters, fountain with particle spray, Leaderboard moved here at (-120,15.5,15) facing +X with gold neon frame |
| `Paths` | | arena to plaza, gym, eggs; eggs to portals; plaza to gym |
| `Lamps` | 11 around the hub | warm dim bulbs (255,190,110), PointLight 0.6, no shadows |
| `Cliffs` | west x=-260, north z=190, south z=-190, track sides z=+-95 (x 60..420) | layered sandstone cliffs with grass tops, front steps |
| `Pond` | x -227..-183, z -32..32 | white rim, glass water, waterfall off the west cliff with foam particles, lily pads |
| `Trees`, `Hills`, `Flowers` | outside the built zones | 54 store trees recolored (green, lime, pink, gold), 9 sunk hill balls, 60 flowers |

## Worlds (`Workspace.Map.Worlds.World2..5`)
Ground parts recolored per theme (Candy pink, Frost snow, Lava basalt, Space slate). Each world folder has:
- Floating island underside (5 tapered rock layers + spike) and an edge lip (neon on Lava).
- Egg plaza around the two stands with glow rings and 4 pillars with orbs.
- Spawn ring and a path to a big striped arch over ReturnPortal (orb on top).
- `Extra`: 12 edge mounds, 36 big theme props, 6 small floating islets around the edge.
- Props: Candy (lollipops, canes, cupcakes, gumdrops), Frost (snow pines, ice crystals, snowmen, igloos), Lava (volcanoes with Fire, lava pools, obsidian), Space (ringed planets, crystals, rockets, craters).
- Center corridor (|x| < 45, z -60..110 from center) kept clear for spawn, eggs and the return portal.

## Lighting
Brightness 2.6, ClockTime 14.5, Ambient (95,100,130), OutdoorAmbient (130,130,160), warm ColorShift_Top, ShadowSoftness 0.35. ColorCorrection "SlopColor" saturation 0.35, contrast 0.12. Bloom 1 / size 28 / threshold 1.2. SunRays 0.12. Atmosphere density 0.3, blue tint, haze 1.2. `Clouds` in Terrain (cover 0.55). DepthOfField off.
**Set `Lighting.Technology` = Future by hand** (scripts can't set it).

## Inserted assets
| Asset id | What | Scripts found |
|---|---|---|
| 12549617200 | "Low Poly Tree" (Remadex Development), 2 MeshParts + 1 Weld | none (Weld removed). Source copy in `ServerStorage.AssetStaging` |
| 7447638611 | "Stud Texture" decal (born2swaos), image 7447638591 | n/a (image only) |

## Related
- [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Stat Sim Design|Stat Sim Design]]
- [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Layout Contract|Stat Sim Layout Contract]]
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Store Asset Vetting|Store Asset Vetting]]
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Studio MCP Gotchas|Studio MCP Gotchas]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
