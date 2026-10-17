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
updated: 2026-10-17
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
- Current team-only spawns: Spawn_West blue (-186,.9,-115), Spawn_East red (182,.7,108), inside the later compact boundary; see [[Crouch And Compact Map]].

## Tested
- Playtest: character lands on the ground in the rear alley, both cut-throughs, and the sidewalk. No map errors in Output.

## Pass 2: facade grime (2026-10-16)
![[2026-10-16-map-pass2-alley.jpg]]
![[2026-10-16-map-pass2-facade.jpg]]
- **Boarded windows:** 155 (plywood + 2 crooked planks). About 1 in 5 buildings is "abandoned" with most windows boarded.
- **Window AC units:** 51 on upper floors, with brackets.
- **Gutters + downspouts** on all 24 rowhouses (front downspout at the lot line, rear gutter on the alley side). About 40% rusted.
- **Rear fire escapes** on about a third of the 3-story rowhouses, rusted, drop ladders start 6 studs up. New alley-side climb routes (no gameplay yet).
- **Rust:** 255 metal parts switched to CorrodedMetal (fences, stoop rails, apartment fire escape, chain-link, dumpsters, transformers, loading doors).
- **Stains:** grime streaks from rooflines, rust runs, splash-back at the base on 68 walls. Drawn with SurfaceGui frames + UIGradient on invisible, non-collidable panels.
- **Graffiti:** 30 panels, TextLabels in marker/bubble fonts. Made-up tags only (NOVA, ZEKO, FRESH, LUMO, RIZE, ECHO, ...). No gang names, sets, numbers, or real places. In cut-throughs, rear alleys, east alley, and end walls.
- New module: `ServerStorage.MapTools.WallOverlay` (`carrier`, `streak`, `tag`). Details live in each building's `Details` folder, graffiti in `Workspace.Map.Props.Graffiti`.
- Map is now about 2,940 parts, 98 SurfaceGuis, 0 scripts. Playtest clean.
- Known: some tags sit on shadowed walls and read dark until the lighting pass.

## Pass 3: real prop meshes (2026-10-16)
![[2026-10-16-map-pass3-street.jpg]]
![[2026-10-16-map-pass3-alley.jpg]]
- All props made with Studio `generate_mesh` (original, AI-generated, no store models, no scripts). Templates in `ServerStorage.MapTools.PropMeshes`, pivot at bottom-center, so `template:Clone():PivotTo(CFrame.new(groundPos))` just works.

| Template | Size (studs) | Asset id | Used for |
|---|---|---|---|
| Sedan90s | 6.7 x 4.7 x 12.6 | 96978436847406 | red 90s sedan, parked |
| Sedan70s | 7.7 x 5.4 x 14.5 | 122440127787877 | long black 70s sedan, parked |
| Dumpster | 8.5 x 5.3 x 5.0 | 90744276607422 | alleys + cut-throughs (replaced boxes) |
| WheelieBin | 2.9 x 3.8 x 2.9 | 119882404822242 | behind rowhouses on the alley side |
| TrashCan | 2.4 x 3.5 x 2.4 | 132618953874721 | sidewalks (replaced boxes) |
| Hydrant | 1.7 x 3.0 x 1.5 | 138617606034462 | curbs (replaced boxes) |
| StreetTree | ~20 x 24 x 21 | 99028012992380 | sidewalk tree pits |

![[2026-10-16-map-pass3-prop-lineup.jpg]]
- Placed: 18 parked cars (15 on the street, 3 in the west lot), 13 street trees with dirt pits, 24 wheelie bins, 9 dumpsters, 5 trash cans, 4 hydrants.
- Collision: cars, bins, cans, hydrants collide (Hull). Tree crowns don't; each tree has an invisible trunk collider.
- Tested: walking into a car stops at its side, standing under a tree crown works, no errors.
- Gotcha: generated models come in with the pivot at the middle. Move the pivot to the bottom before placing, or they sink halfway into the ground.
- Known: the tree reads a bit savanna. Swap for a rounder deciduous tree later if it bugs us.

## Pass 4: Cade's fixes (2026-10-16)
Cade's notes on pass 3: trees too small and fake (single straight trunk), graffiti looked fake and suburban, cars looked like textured blobs and too frequent. Garbage cans were good.

![[2026-10-16-map-pass4-sidewalk.jpg]]
![[2026-10-16-map-pass4-canopy.jpg]]
- **Trees:** replaced the AI tree with 6 real oaks from a free PBR pack (Creator Store `98950444096614`, Letaij, no scripts). Forked trunks and spreading branches, 40 to 52 studs tall, crowns up to 64 wide. 16 planted in sidewalk pits; the canopy closes over the street like [[Overcast Rowhouse Street]].
  - Gotcha: the pack's meshes have the pivot on a leaf clump, not the trunk (OakD was 21 studs off). Found each trunk with horizontal raycasts at 1 stud using `PreciseConvexDecomposition`, then moved the pivot. Trunk colliders are sized to the measured trunk width. Players slide around trunks, leaves don't block.
- **Cars:** replaced the AI sedans with 9 real modeled old cars, scaled 1.1x (18 to 24 studs long). Down from 18 to 12 placed (10 on the street, 2 in the west lot).
  ![[2026-10-16-map-pass4-car-lineup.jpg]]
  - Sources: `93702862785504` (old sedan), `4128316898` (white 70s sedan, bearduckmonkey), `8616820527` (rusty car pack, xavier2007, 7 used). All scripts removed.
  - **Rejected for hidden scripts:** `116549755605901` (22 scripts incl. "PoseLink", "Wave"), `84448302369434` (31 scripts), and `93702862785504` came with `Runtime` + `ScreenBuilder` scripts despite claiming none (backdoor pattern). Mesh kept, scripts deleted. Always strip and check store models.
  - Gotcha: GetBoundingBox follows the PrimaryPart's tilt, so use a world AABB from part corners to orient cars. One car ended up upside down from a bad rotation and was fixed.
- **Graffiti:** see [[Graffiti Style]]. Font text removed. Our 13 original pieces uploaded and layered over tag walls on all 19 spots (45 panels), with a few store decals mixed in.
- Templates: `ServerStorage.MapTools.PropMeshes` now has OakA-F and 9 `Car_*`. Old AI `Sedan90s`, `Sedan70s`, `StreetTree` removed. AI dumpster, wheelie bin, trash can, hydrant kept.
- Playtest clean. Car collision works, 0 scripts in the map or templates, about 3,000 parts.

## Next passes (one at a time)
1. ~~Real prop meshes~~ done in pass 3, cars and trees redone in pass 4.
2. ~~Facade detail~~ done in pass 2.
3. Rooftop routes and more fire escapes on rowhouses.
4. Spawns, capture zones (corner store, court, laundromat per the design doc) and map boundary.
5. ~~Lighting~~ pass 1 done, see [[Lighting And Atmosphere]]. Wet asphalt + night variant still to do.

## Related
- [[Art Direction]]
- [[Hood Warfare 2 Blockout Workflow]]
- [[Main Street Routes and Cover]]
- [[Map Asset Registry]]
- [[Map Tools]]
- [[Lighting And Atmosphere]]
- [[Graffiti Style]]
- [[01 Game Design/O Blah Warfare Design]]
- [[index]]

## Pass 5: "it's a hood, not a ghost town" (2026-10-16, Cade's feedback)
Cade's notes after the realism pass: sewer fog looked bad, too many rusty cars, textures too contrasty and cracked, same red wall everywhere, sidewalks black/white, fake store interiors, too much like NY brownstones, night lights too broad, needs two spawns, whole scene too run down.

- **Spawns:** `Workspace.Map.Spawns.Spawn_West` (-190, 0, 0, dead end in front of the apartment block) and `Spawn_East` (232, 0, -4, east alley gap). Invisible, non-colliding, neutral, attribute `Side`. Old center `SpawnLocation` removed. Each has a wall light. Team logic is GAME FLOW's job.
- **Fog:** manhole steam and fixed fog bands removed. New client-only `StarterPlayer.StarterPlayerScripts.MapFogClient` keeps a low fog ring ~26 studs around the camera (attributes `Radius`, `Height`). Visual only.
- **Cars:** 10 total (8 street, 2 west lot), mostly everyday cars: modern sedan in white/grey/maroon/black (repaintable, store 140665250936542, 7 config scripts removed) and a blue sedan (store 951086064, 71 chassis scripts removed), plus 3 older ones.
- **Less run-down:** 444 boarded panels removed (2 back buildings keep boards), all grime streaks gone, 150 fence pieces painted black, fire escapes black, every porch bulb on, about half the road cracks and patches gone, no cracked/tilted slabs, flies only on dumpsters, 51 more windows lit at night.
- **Textures:** new `HW_BrickMuted` on almost every building with per-building tints, `HW_PaintedBrick` on 2 houses, `HW_VinylSiding` on the upper floors of 3 townhomes. Road back to plain Roblox asphalt (generated asphalt failed). Sidewalks on plain `HW_ConcreteGrey`. Stone trim and stoops on plain concrete.
- **Townhomes:** 10 rowhouses (N1-3, N8-10, S3-5, S11) converted to porch townhomes like [[Night Porch Firefight]]: cornice and stoop removed, raised concrete porch with steps, porch roof on white posts, railing, chain-link with a gate along the sidewalk. Tagged `Townhome`.
- **Store interiors:** deli and laundromat panes now show a bare dim room (`win_dark`). Signs, neon OPEN and posters stay. Real interiors later.
- **Night:** lamps Angle 105, Range 36, Brightness 2.8; ambient raised so unlit areas are dim, not black. Values in [[Lighting And Atmosphere]].
- Playtest: spawned at the east spawn, fog ring follows the camera, no errors.

## Pass 6 (2026-10-16)
- Active look set to **Overcast (day)** so the fog shows.
- Last old cars replaced: 2 modern crossovers (store 116917516767193, no scripts, aligned by its body part because its bounding box is almost square) and a silver modern sedan. All 10 cars are modern now. Old car templates deleted.
- Night brightened: Brightness 0.8, Ambient 52,48,50, OutdoorAmbient 88,84,88, Exposure 0.5.
- New [[Map VFX Library]]: burn barrels, transformer sparks, dryer vent steam, gusting leaves, lamp dust.

## Ground and opposite-corner team spawns (2026-10-17, Codex)
- User-confirmed bounded update to place 127865723083651. Checker came from Workspace.Baseplate.Texture, not missing collision geometry.
- Baseplate.Material now Asphalt, matching MainRoad color (#58585a); checker texture hidden. Dimensions, transform and collision unchanged.
- Spawn_West blue at (-235,.5,-135); Spawn_East red at (245,.5,135). Both face center, are non-neutral and retain three-second native protection.
- Two native AutoAssignable Teams using requested labels; no new scripts or map signage.
- Tested 162 clear spawn footprint samples and 1590 collidable floor rays; native automatic team assignment and actual PLAY deployment/protection expiry for both teams passed sequentially in one client session.
- Restore function passed against isolated modified clones; live update retained. Backup: ServerStorage.GroundTeamSpawnsBackup_20261017.
- Buildings, lighting, weapons, movement and menu sources unchanged. Simultaneous multiplayer balancing/combat remains untested.
- Evidence: [[04 Scripts/Ground And Team Spawns/Implementation|Ground And Team Spawns Implementation]]. Related: [[Sprint Slide And Map Boundary]], [[2026-10-17]].

## Later 2026-10-17: compact border and floor repair
- [[Crouch And Compact Map]] supersedes the earlier corner-pad coordinates: current blue (-186,.9,-115), red (182,.7,108).
- Wall inner faces X[-236,246], Z[-122,122] now touch outer building extents. Footprint area 26.5868% smaller; no buildings moved.
- Removed apron/baseplate overlap, repaired sidewalk tile/soil/curb layering and hid a redundant road patch. Broad coplanar floor pairs 12 -> 0; full collision retained.
- Both actual spawns passed; 242 pad rays and 900 boundary rays passed. Minimap boundary proxies updated.
- Original geometry retained in ServerStorage.CrouchCompactFloorBackup_20261017; exact rollback passed on isolated copies.
## Curb z-fight fix (2026-10-17, Claude)
- Cause: each `Sidewalk` side facing the street sat in the same plane as the `Curb` face (e.g. both at z=-20). The 0.3-stud strip of curb above the road showed two materials fighting.
- Fix: those sidewalk sides pulled back 0.05 under the curb (corner sidewalk at x=160 and z=20 too). Long sidewalks' x=148 ends left alone (hidden by the corner sidewalk).
- Road decals re-layered so no two overlapping tops share a height: Gutter 0.23, Patch 0.26, OilStain 0.29, Crack 0.32 (0.34/0.39 where they overlap others or lines), ParkLine/CenterLine 0.35, Crosswalk 0.37, StormDrain/ManholeRing 0.36, Manhole 0.38. Road top is 0.2. Cylinders extended down to the road instead of floating.
- Tree pits (16): side curb pieces shortened 0.6 so the corners don't overlap.
- Scan of all Ground + tree pit faces: visible coplanar pairs 0 (left: hidden end faces at x=148/-200 and the boundary walls).
- Backup: `ServerStorage.CurbZFightBackup_20261017` (Sidewalks, Street, RoadDetail, TreePits).

## Co-op zombie direction — 2026-10-17
- [[Zombie Lobby And Co-op Queues]] reuses 18 copies of this map's existing assets in a separate 212x158 lobby at X=1000; original street geometry is retained.
- Previous blue/red split pads are now disabled. Everyone is Survivors; every co-op party deploys at the same (0,4.6,0) transform. Historical spawn coordinates above no longer define current join/deploy flow.
