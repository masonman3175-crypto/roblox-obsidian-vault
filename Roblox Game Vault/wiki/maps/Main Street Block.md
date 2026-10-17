---
type: map
area: maps
owner: shared
status: building
sources:
  - raw/2026-10-16-overcast-rowhouse-street.png
  - raw/2026-10-16-night-porch-firefight.png
  - raw/2026-10-16-fps-reference.png
  - raw/2026-10-16-map-pass1-street.jpg
  - raw/2026-10-16-map-pass1-overhead.jpg
  - raw/2026-10-16-map-pass1-rear-alley.jpg
  - raw/2026-10-16-map-pass1-cut-through.jpg
updated: 2026-10-16
tags: [map, blockout, environment]
---

# Main Street Block

First real map block in **hood warfare 1.2** (place `127865723083651`). Geometry only: no interiors, no lighting or shader work, no scripts.

![[2026-10-16-map-pass1-street.jpg]]

## Built from
- [[Overcast Rowhouse Street]]: brick rowhouses, stoops, iron fences, power lines, bus shelter.
- [[Night Porch Firefight]]: stoops and porches as cover, chain-link, alley clutter.
- [[Hood Warfare 2 Urban Routes]]: three route layers (main street, rear alleys, cut-throughs) and three landmarks.
- `raw/2026-10-16-fps-reference.png`: street-level scale check.

## Layout (studs, ground top at Y 0)
- **Main street** runs along X from -200 to 160. Road 40 wide (2 lanes + parking), sidewalks 12 wide with curbs, small fenced front yards.
- **Cross street** at X 160 to 200, crosswalk at the intersection.
- **North and south rows:** 12 rowhouses each, 2 to 3 stories, stoops, cornices, some bay windows, rooftop access boxes. Lots 20 to 22 wide.
- **Rear alleys** 14 wide behind each row (Z +/-74 to 88), chain-link on the far side, dumpsters, pallets, poles with wires.
- **Cut-through alleys:** north at X -14 to -2, south at X 52 to 64. Link street to rear alley.
- **Back buildings** (Z +/-94 to 122) wall in the alleys. **East block** across the cross street with its own alley gap.
- **Landmarks:** corner store (NE corner, red awning), laundromat (SE corner, blue awning), 5-story apartment block with fire escape closing the west end.
- **West end:** fenced vacant lot (north, future court) and parking lot (south).

![[2026-10-16-map-pass1-overhead.jpg]]
![[2026-10-16-map-pass1-rear-alley.jpg]]
![[2026-10-16-map-pass1-cut-through.jpg]]

## In Studio
- Everything under `Workspace.Map`: `Ground`, `Buildings` (NorthRow, SouthRow, Landmarks, BackShells, EastBlock), `Alleys`, `Fences`, `Props`, `Utilities`.
- Rowhouse builder: `ServerStorage.MapTools.RowhouseKit` (ModuleScript, edit-time only). `Kit.house(parent, {x1, x2, side, stories, color, doorBay, bay, roofBox, name})`.
- About 2,025 parts, all anchored, zero scripts. Power lines are Beams between Attachments.
- Old `Map_10v10` blockout was deleted on Cade's call. Roll back with File > Version History if needed.
- `Workspace.SpawnLocation` still sits in the middle of the road at 0,0,0. Spawns are not placed yet.

## Tested
- Playtest: character lands on the ground in the rear alley, both cut-throughs, and the sidewalk. No map errors in Output.

## Next passes (one at a time)
1. Swap box props for real meshes (cars, dumpsters, trees) with generate_mesh or stripped static assets.
2. Facade detail: graffiti, boarded windows, AC units, gutters, rust (Design doc look list).
3. Rooftop routes and fire escapes on rowhouses.
4. Spawns, capture zones (corner store, court, laundromat per the design doc) and map boundary.
5. Lighting and materials pass last.

## Related
- [[Art Direction]]
- [[Hood Warfare 2 Blockout Workflow]]
- [[01 Game Design/O Blah Warfare Design]]
- [[index]]
