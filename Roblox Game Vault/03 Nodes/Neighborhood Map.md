# OBlock Rivals Map

## Roblox Studio object
`Workspace.OBlockRivals_Map`

## Status
The previous large neighborhood map was replaced with a compact, environment-only map. No weapons, combat scripts, teams, HUD, shops, currency, leaderboards, or player systems were created.

## Compact scale and layout
- Approximate playable footprint: **660 × 660 studs** after a `0.55` model scale pass
- **Blue West District:** apartment complex, houses, rec center, basketball court, parking, alleys, fences, blue environmental accents
- **Red East District:** apartments, houses, convenience store, gas station, warehouse, side streets, fenced backyards, red environmental accents
- **Center:** grocery store, laundromat, courtyard, playground, abandoned storefronts, central intersection, traffic lights, multiple routes

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

## Boundary system
- Four solid, anchored collision walls surround the map at approximately **X/Z = ±350**
- Walls are about **22 studs high** and **5 studs thick**, so players cannot leave the neighborhood
- Concrete boundary pillars, metal fence caps, perimeter lamps, and a boundary sign make the edge read as part of the environment
- The boundary is contained in `Workspace.OBlockRivals_Map.MapBoundary`

## Detail pass included
- Brick and concrete materials
- Window frames and glass variation
- Fire-escape platforms
- Rooftop units and access ladders
- Storefront signage
- Original fictional graffiti
- Parked cars and dumpsters
- Chain-link fences
- Street lamps with PointLights
- Traffic signals, street signs, crosswalks, lane markings
- Storm drains, potholes, sidewalks, curbs, and alleys
- Basic enterable shells for the grocery store and laundromat
- Overcast daytime lighting and atmospheric fog

## Hyper-realism pass
- More natural ambient/reflected light, restrained color correction, contrast, and atmospheric fog
- Overcast daytime lighting with Future technology when available
- Current map verification: **1,477 descendants**, including **75 boundary children**

## Design reference
The layout uses broad urban FPS conventions—dense blocks, mixed residential/commercial routes, indoor/outdoor paths, and multiple sightlines—inspired by the genre and the user-provided Hood Warfare 2 reference. Buildings, names, graffiti, and layout are original.

## Next environment-only pass
- Add more enterable rooms and stairwells.
- Add modular wall/roof pieces for faster expansion.
- Add more detailed props and weathering.
- Test StreamingEnabled and collision performance.
