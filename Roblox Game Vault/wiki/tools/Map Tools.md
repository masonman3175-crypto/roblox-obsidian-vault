---
type: tool
area: tools
owner: shared
status: building
sources:
  - Studio: ServerStorage.MapTools (hood warfare 1.2)
updated: 2026-10-16
tags: [tool, studio, map, modules]
---

# Map Tools

Everything Claude built to make the map lives in `ServerStorage.MapTools` (hood warfare 1.2). These are **edit-time** helpers: they build or style the map from the Studio command bar or the Studio MCP `execute_luau`. Nothing here runs in a live game unless someone wires it.

Use from the command bar: `local Kit = require(game.ServerStorage.MapTools.RowhouseKit)`.

## RowhouseKit (ModuleScript)
Builds one brick rowhouse from parts.
- `Kit.house(parent, opts)` returns a Model.
  - `x1`, `x2`: lot edges on X (studs). `side`: `1` = north row, `-1` = south row.
  - `stories` (2 or 3), `color` (brick Color3), `doorBay` (which bay gets the door), `bay` (bool, bay window), `roofBox` (bool, rooftop access box), `name`.
- Facade sits at `z = 38 * side`, lot runs back to `z = 74 * side` (36 deep). Story height 11, first floor raised 3 (stoop).
- Makes: body, foundation, cornice + cap, parapet, windows with sills and lintels, door + transom + stoop with rails, rear windows, rear door, front iron fence with a gate gap.
- `Kit.box(parent, name, x1, x2, y1, y2, z1, z2, color, material)`: axis-aligned part from min/max corners. Handy for anything boxy.

## WallOverlay (ModuleScript)
Draws on walls with SurfaceGuis. Used for grime stains (pass 2).
- `carrier(parent, name, cf, w, h, ppu)`: invisible, non-collidable panel flush with a wall. `cf.LookVector` = wall outward normal. Returns its SurfaceGui.
- `streak(gui, x, y, w, h, color, alpha)`: vertical stain that fades downward (UIGradient). Positions are 0..1 of the panel.
- `tag(gui, text, font, fill, stroke, rot)`: text tag. **Retired for graffiti** (looked fake, see [[Graffiti Style]]). Still fine for signs.

## LightingPresets (ModuleScript)
- `apply("Overcast")` or `apply("Night")`. Sets Lighting props, `MapAtmosphere`, `Terrain.Clouds`, `MapGrade`, Bloom, every practical light (via `Day*`/`Night*` attributes) and `NightWindow` windows. Writes `Lighting:GetAttribute("MapPreset")`.
- Details and values: [[Lighting And Atmosphere]].

## PropMeshes (Folder of templates)
Clone, then `:PivotTo(CFrame.new(groundPos) * CFrame.Angles(0, yaw, 0))`. Every template's pivot is **bottom-center** (trees: trunk base), world-upright, scripts stripped.
- Trees: `OakA` to `OakF` (40 to 52 tall, trunk collider inside).
- Cars: `Car_Black60s`, `Car_BlueCompact`, `Car_DarkRed`, `Car_GreyBlue`, `Car_RedVan`, `Car_RoofRust`, `Car_RustBeige`, `Car_RustRed`, `Car_White70s`. Long axis on Z, so yaw 90 parks along the street.
- Street stuff: `Dumpster`, `WheelieBin`, `TrashCan`, `Hydrant`.
- Sources and ids: [[Map Asset Registry]].

## GraffitiDecals (Folder of Decal templates)
- `O_*` = our 13 original pieces. `G_*` = 8 vetted store decals.
- Each has an `Aspect` attribute (width / height) and a `Source` attribute.
- Place on an invisible carrier part, `Decal.Face = Front`. Rules in [[Graffiti Style]].

## LightingBackup (Folder)
- The Lighting service as it was before Claude touched it: every property as an attribute, plus clones of Sky, SunRays, Atmosphere, Bloom, DepthOfField, MapNightAtmosphere. Use it to roll back.

## Related
- [[Main Street Block]]
- [[Map Asset Registry]]
- [[Studio MCP Gotchas]]
- [[index]]
