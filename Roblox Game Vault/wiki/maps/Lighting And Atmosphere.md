---
type: map
area: maps
owner: shared
status: building
sources:
  - raw/2026-10-16-overcast-rowhouse-street.png
  - raw/2026-10-16-night-porch-firefight.png
  - raw/2026-10-16-lighting-pass1-street.jpg
  - raw/2026-10-16-lighting-pass1-alley.jpg
updated: 2026-10-16
tags: [lighting, atmosphere, map]
---

# Lighting And Atmosphere

Lighting pass 1 for [[Main Street Block]] (2026-10-16). Goal: the grey overcast feel of [[Overcast Rowhouse Street]] with the warm practical lights of [[Night Porch Firefight]], while staying readable for gunfights.

![[2026-10-16-lighting-pass1-street.jpg]]
![[2026-10-16-lighting-pass1-alley.jpg]]

## Sky and grade (Lighting service)
| Setting | Value | Why |
|---|---|---|
| ClockTime | 17.3 | late-afternoon overcast. 18.35 (true dusk) was too dark to fight in |
| GeographicLatitude | 41 | low sun angle |
| Brightness | 1.9 | |
| Ambient / OutdoorAmbient | 62,66,76 / 124,128,140 | cool grey fill so shadows aren't black |
| ExposureCompensation | 0.25 | |
| ShadowSoftness | 0.6 | soft overcast shadows |
| ColorShift Top / Bottom | 70,60,55 / 20,22,28 | |
| `MapAtmosphere` | Density 0.36, Offset 0.12, Haze 2.2, Glare 0.15, Color 162,162,168, Decay 96,88,92 | grey haze, distance fades |
| `Terrain.Clouds` | Cover 0.88, Density 0.72, Color 120,118,122 | heavy overcast |
| `MapGrade` (ColorCorrection) | Saturation -0.3, Contrast 0.12, Tint 242,238,236 | desaturated, gritty |
| Bloom | Intensity 0.7, Size 28, Threshold 1.6 | bulbs and lamps glow |
| SunRays, DepthOfField | disabled | |

- Removed the duplicate Atmosphere (`MapNightAtmosphere` + `Atmosphere` were both active).
- **Backup** of the old Lighting (all properties as attributes + every child) is in `ServerStorage.MapTools.LightingBackup`.
- **To do by hand:** `Lighting.Technology` can't be set from a script. Set it to **Future** in the Properties panel so point and spot lights cast shadows. (Current value unknown.)

## Practical lights (`Workspace.Map`)
- **Streetlights** (`Utilities.StreetLights`, 13): cobra-head lamps. 7 on poles along the north curb, 4 arms bolted to every other wooden utility pole on the south side, 2 at the intersection corners. Neon lens + SpotLight down, sodium orange 255,168,92, Range 46, Brightness 3.2, shadows on.
- **Porch lights** (19 rowhouses with a front door): wall sconce beside the door. 14 on (warm 255,196,128, Range 14, about a third with shadows), 5 dead bulbs.
- **Alley wall packs** (11): over rowhouse rear doors, mix of orange and cold white, Range 22, half with shadows.
- **Storefronts:** corner store (warm) and laundromat (cool) use dark reflective glass with a SurfaceLight spilling onto the sidewalk. Flat glowing glass looked fake without interiors.
- **Apartment entry:** SpotLight under the canopy.
- **Lit windows:** 66 random windows switched to dim Neon (mostly warm, some TV blue), tagged `LitWindow`.

## Budget
- 50 lights, 27 shadow-casting. 60 fps in a Studio playtest on Cade's PC (this is not a phone test).
- If mobile struggles: turn shadows off on porch lights and wall packs first, keep streetlights.

## Night variant (2026-10-16)
Matches [[Night Porch Firefight]]: dark blue moonlight, warm porch pools with hard shadows on the brick, tight sodium pools on the street with dark gaps between them.

![[2026-10-16-lighting-night-street.jpg]]
![[2026-10-16-lighting-night-porch.jpg]]

- **Switching:** `ServerStorage.MapTools.LightingPresets` (ModuleScript). `require(it).apply("Overcast")` or `.apply("Night")`. Sets Lighting, `MapAtmosphere`, Clouds, `MapGrade`, Bloom, every practical light, and the night-only windows. Writes the active name to `Lighting:GetAttribute("MapPreset")`.
- Each light has `DayBrightness`/`DayRange`/`NightBrightness`/`NightRange` attributes. 69 extra windows are tagged `NightWindow` (glow only at night, `DayColor`/`NightColor` stored).
- Night values: ClockTime 0.4, Brightness 0.9, Ambient 32,36,50, OutdoorAmbient 70,80,108, Exposure 0.55, ShadowSoftness 0.15, Atmosphere Density 0.33 dark blue, Clouds Cover 0.65 dark, grade Saturation -0.12 cool tint, Bloom 1.1 / threshold 1.15.
- Streetlights at night: Brightness 2.2, Range 34, Angle 95. **Shadows off on streetlights** (both presets) because the oak canopy was swallowing their light. Porch lights at night: Brightness 3, Range 16, shadows on (they make the hard brick shadows).
- Tested: 60 fps, worst frame 19 ms, 21 shadow lights, switching both ways restores everything.
- Gotcha: in Studio, lights only render near your real viewport camera. Screenshots taken far from it look unlit. Not a game bug.
- Runtime switching (map rotation, night mode) is GAME FLOW's call. Move the module to ServerScriptService or ReplicatedStorage when they wire it.

## Next
- Wet asphalt (MaterialVariant) and puddles to catch the sodium light.
- Streetlight flicker and a couple of dead streetlights for mood (needs a client script, GAME FLOW to sign off).

## Related
- [[Main Street Block]]
- [[Art Direction]]
- [[index]]
