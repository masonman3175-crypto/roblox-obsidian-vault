---
type: map
area: maps
owner: shared
status: building
sources:
  - Studio: Workspace.Map, ServerStorage.MapTools (hood warfare 1.2)
updated: 2026-10-16
tags: [map, assets, credits, registry]
---

# Map Asset Registry

Every outside asset in [[Main Street Block]], where it came from, and what it's used for. Check here before adding a new asset so we don't double up, and before publishing for credits.

## Store models (stripped of scripts)
| Template | Store id | Creator | Used | Notes |
|---|---|---|---|---|
| OakA to OakF | 98950444096614 | Letaij | 16 street trees | PBR oak pack, no scripts. Pivots moved to trunks. |
| Car_RoofRust | 93702862785504 | (blank name uploader) | 1 | Came with hidden `Runtime` + `ScreenBuilder` scripts, deleted. See [[Store Asset Vetting]]. |
| Car_White70s | 4128316898 | bearduckmonkey | 2 | Clean. Was flipped by a bad rotation, fixed. |
| Car_Black60s, Car_RedVan, Car_RustBeige, Car_BlueCompact, Car_RustRed, Car_DarkRed, Car_GreyBlue | 8616820527 | xavier2007 | 9 | "Abandoned, Rusty Cars" pack, no scripts. One 1930s car in the pack not used. License of original meshes unclear (uploader imports from Sketchfab) (unverified). |

## AI-generated meshes (Studio `generate_mesh`, ours)
| Template | Asset id | Used |
|---|---|---|
| Dumpster | 90744276607422 | 9 (alleys, cut-throughs) |
| WheelieBin | 119882404822242 | 24 (behind rowhouses) |
| TrashCan | 132618953874721 | 5 (sidewalks) |
| Hydrant | 138617606034462 | 4 (curbs) |
| ~~Sedan90s~~ | 96978436847406 | removed (looked like a blob) |
| ~~Sedan70s~~ | 122440127787877 | removed |
| ~~StreetTree~~ | 99028012992380 | removed (single straight trunk) |

## Graffiti images
- **Ours (uploaded 2026-10-16):** 13 image ids, listed in [[Graffiti Style]]. Made with the [[Graffiti Generator]].
- **Store decals:** 8, listed in [[Graffiti Style]] with decal id and image id.

## Rejected store assets (do not use)
| Store id | Why |
|---|---|
| 116549755605901 | "French sedan": 22 scripts (PoseLink, Wave...), 151 studs of extra junk |
| 84448302369434 | "SUV": 31 scripts, 722 parts |
| 11343475900 | named "car", actually an apartment building mesh |
| 23155948, 18919165439, 2078271190, 38149439, 93169165, 30520502 | graffiti decals with brands, IP, or real people |

## What's in Workspace.Map (2026-10-16)
Total: 3,168 parts, 202 models, 50 lights, 45 decals, 0 scripts.

| Folder | Contents |
|---|---|
| Ground | Street (road, lines, crosswalk), Sidewalks (walks, curbs, front yards), vacant lot, parking lot |
| Buildings.NorthRow / SouthRow | 12 rowhouses each (RowhouseKit) + `Details` (boards, AC units, gutters, fire escapes, stains, porch + alley lights) |
| Buildings.Landmarks | CornerStore, Laundromat, ApartmentBlock |
| Buildings.BackShells | 20 buildings walling in the rear alleys |
| Buildings.EastBlock | 4 buildings across the cross street + alley gap |
| Alleys | rear alley ground, 2 cut-throughs |
| Fences.ChainLink | 108 parts along the alleys and west lots |
| Props.StreetProps | bus shelter, 5 trash cans, 4 hydrants |
| Props.AlleyClutter | 9 dumpsters, 24 wheelie bins, pallets, trash bags |
| Props.Graffiti | 45 decal panels (19 walls) |
| Props.ParkedCars | 12 cars |
| Props.StreetTrees | 16 oaks + tree pits |
| Utilities.PowerLines | 23 wooden poles with Beam wires |
| Utilities.StreetLights | 13 sodium streetlights |

## Related
- [[Map Tools]]
- [[Store Asset Vetting]]
- [[index]]
