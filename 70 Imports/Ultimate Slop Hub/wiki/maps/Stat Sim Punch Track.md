---
type: map
game: Stat Sim
owner: cade
status: building
sources:
  - games/Stat Sim/Layout Contract.md (v2)
  - Studio place 98823628319724 (ultimate slopp v1)
updated: 2026-10-17
---

# Stat Sim Punch Track

`Workspace.Map.Track`, x 40 to 6070, centerline z=0. Follows [[70 Imports/Ultimate Slop Hub/games/Stat Sim/Layout Contract|Stat Sim Layout Contract]]; hub side is [[70 Imports/Ultimate Slop Hub/wiki/maps/Stat Sim Map|Stat Sim Map]].

## Layout
| Folder | x | Ground | Scenery |
|---|---|---|---|
| GrassFields | 40-1040 | 20 striped strips z -60..60, top y=0.15 (sits over Hub.Ground.Grass top 0.10) | hills, 42 trees, 90 flowers, clouds, white fence z=-62 |
| Desert | 1040-2040 | strips + side ground z -500..250 (filler from x 1024) top 0 | cacti (mesh), dunes, 4 stepped pyramids, mesas, oasis + palms, tumbleweeds |
| SnowMountains | 2040-3040 | same | 11 peaks (crossed wedges + snow caps), 60 pines (mesh), igloos, snowmen, ice crystals, snowfall particles |
| Volcano | 3040-4040 | same | 4 stacked-cylinder volcanoes (neon crater, lava drips, smoke + ember particles), 2 lava rivers, glow rocks, spikes, ash clouds |
| CandyLand | 4040-5040 | same | candy canes, lollipops, gumdrops, cotton candy trees, chocolate river, gummy bears (mesh), sprinkles |
| OuterSpace | 5040-6040 | same | dark backdrop walls (far z=-490, end x=6125, near z=260) with 220 neon stars, planets + Earth, craters, glow crystals, floating rocks, moon base domes, flag, rockets (mesh), star dust |
| Finish | ~6060-6070 | EndGround | MaxWall + "MAX! / 10M FT" sign, rim neons, crash pad |
| DistanceBoards | every 250, z=-35 | | 10 FT at x=40 up to 10M FT at x=6040 (10^(1+(x-40)/1000)) |

Each biome has `Arch` (legs at z=-42 and z=+56, beam y 92-118 with name on both faces) and a low `NameSign` at z=-50 facing the camera.

## Corridors
Nothing taller than y=8 in z 0..45 and nothing in z -8..8 (flowers/sprinkles/tumbleweeds only at z<-12).

## Generated meshes (generate_mesh, 0 scripts in all)
- Cactus (Desert): asset id not captured (connection dropped)
- Snowy pine: 101793755957244 (mesh rbxassetid://75043161780869)
- Gummy bear: 123386437142948 (mesh rbxassetid://87991268611405), most recolored to glass candy colors
- Rocket: 81153294207799 (mesh rbxassetid://101693703270928)
No store assets inserted.

## Todo
- Distance boards are small from the flying camera; consider 1.5x.
- Not checked in a real playtest with the follow camera.
