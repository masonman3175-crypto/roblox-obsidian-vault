# OBlock Rivals Map

## Roblox Studio object
`Workspace.OBlockRivals_Map`

## Status
Compact, environment-only neighborhood. The latest revision focuses on geometry and believable silhouettes, not another texture or lighting pass. No weapons, combat scripts, teams, HUD, shops, currency, leaderboards, or player systems were added.

## Compact scale and layout
- Built neighborhood footprint: approximately **580.8 × 580.8 studs**, down from 660 × 660.
- Building and prop spacing tightened by **12%**; neighborhood area is approximately **22.6% smaller**.
- Building heights and road widths were retained rather than uniformly shrinking everything again.
- **Blue West District:** apartment complex, houses, rec center, visible basketball court, parking, alleys, fences, blue environmental accents.
- **Red East District:** apartments, houses, convenience store, gas station, warehouse, side streets, fenced backyards, red environmental accents.
- **Center:** grocery store, laundromat, courtyard, playground, abandoned storefronts, central intersection, traffic lights, multiple routes.

## Workspace folders
- `Roads`
- `Sidewalks`
- `Buildings`
- `Interiors`
- `Alleyways`
- `Rooftops`
- `Fences`
- `Vehicles`
- `StreetProps`
- `Environment`
- `LightingProps`
- `Decorations`
- `MapBoundary`

## Grounded trees and less-blocky geometry
- Replaced all **28** round-crown trees and sideways cylinder trunks with mesh trees: **23 oaks and 5 pines**.
- Tree placement uses downward raycasts onto actual map surfaces. Visual roots embed by approximately 0.07–0.08 studs instead of hovering.
- Trees use upright, simple trunk collision shapes; foliage does not block players.
- Replaced **26** block cars with curved mesh sedans and simple static collision proxies. Vehicle scripts, controls, and chassis systems were removed.
- Added pitched roofs, gable ends, chimneys, gutters, porch columns, stoops, projecting bay windows, and side windows to eight houses.
- Added dimensional facade details across 23 buildings: parapets, coping, projecting sills, lintels, rear windows, downpipes, rooftop setbacks, and open fire-escape balusters.
- Replaced solid fence sheets with open diamond-wire geometry and round posts/rails.
- Rebuilt sidewalks as separate street segments with raised curbs instead of strips crossing through every road.
- Reattached rooftop access to the actual building roof heights.
- Moved the underground basketball court onto a visible vacant lot.
- Added physical supports to standalone street/district signs.

## Boundary system
- Four solid, anchored collision walls now surround the neighborhood at approximately **X/Z = ±308**.
- Walls remain approximately **22 studs high** and **5 studs thick**.
- Concrete pillars, metal fence caps, perimeter lamps, and a boundary sign remain.
- Perimeter ground strips close the gap between the neighborhood foundation and the walls.
- Boundary objects are contained in `Workspace.OBlockRivals_Map.MapBoundary`.

## Verification
- **28 / 28** tree meshes grounded; zero missing-ground raycasts.
- **116 / 116** sampled perimeter raycasts hit collidable walls.
- Zero unanchored map parts and zero scripts inside the map.
- Geometry checksum: `53240916`; preserved original checksum: `5ce53f22`.
- Rollback was tested on a separate cloned map; the edited live map was retained.
- Original map backup: `ServerStorage.OBlockRivals_GeometryRevision.OriginalMap`.
- This is a geometry/collision check, not an FPS benchmark or a publishing confirmation.

## Existing environment details
Road markings, storm drains, potholes, alleys, storefront signage, fictional graffiti, dumpsters, traffic lights, and overcast lighting remain. Existing interior shells remain unchanged by this revision.

## Asset credits
The street layout and building additions are original. Imported static meshes:
- [Realistic Tree (Mesh)](https://create.roblox.com/store/asset/3564212070) — SheriffTaco.
- [Realistic Oak Tree](https://create.roblox.com/store/asset/128707014921507) — Letaij.
- [Lexus GS300](https://create.roblox.com/store/asset/5344319874) — noshirtjustpants; used as stripped, anchored scenery only.

## Design reference
The map uses broad urban FPS conventions and the user-provided Hood Warfare 2 visual reference without reproducing an existing map.

## Next environment-only pass
- Expand enterable rooms and stairwells.
- Profile rendering on the target devices before increasing detail further.
- Check StreamingEnabled and collision behavior in a full multiplayer test.
