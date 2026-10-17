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
updated: 2026-10-17
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

## Update (pass 5)
- Night now: Brightness 0.6, Ambient 38,35,36, OutdoorAmbient 66,62,64, Exposure 0.3, Atmosphere Density 0.32 Haze 2.2 Color 84,64,50, grade Saturation -0.2. Streetlights Angle 105, Range 36, Brightness 2.8, sodium 255,168,92. Unlit areas dim but readable.
- Spawn wall lights added in `Workspace.Map.Spawns`.
- Ground fog is now a client-side ring around the player (`MapFogClient`), see [[Main Street Block]].

## Dynamic time-of-day lighting (2026-10-17)
Cade inserted the DevForum resource "[V1.1] Realistic Dynamic Lighting | Open Sourced" (by Maiq_S, Isla Natura showcase). It landed twice in `Workspace` as "Dynamic Lighting" folders and its Script was erroring there.

- **Vetted:** read all 13 scripts. No `require(id)`, `loadstring`, `HttpService`, `getfenv`, attributes or tags. It only watches `Lighting.ClockTime` and tweens 7 presets. Clean. See [[Store Asset Vetting]].
- **Kit bugs fixed in our port:** Night band never fired (`>23 and <=6` is impossible), `print` on every change, expects instance names we don't use (`Atmosphere`, `ColorCorrection`), Blur and near DepthOfField would blur the gun. The `;time X` command is from the showcase game, not in the kit.
- **Where it lives now:** `ServerScriptService.MapLighting` = `MapLightingServer` (thin Script) + `DynamicLighting` (ModuleScript) + `LightingBands` (ModuleScript, all 7 bands in one table). Runs on the server so every player gets the same light and exploiters can't flip their own time.
- **Bands:** Sunrise 6-8, Day 8-17, AfternoonGoldenHour 17-18.5, Sunset 18.5-20, Twilight 20-23, Night 23-6. Kit values retuned: OutdoorAmbient raised so shadows stay readable, no Blur/DOF, Night = our tuned Night preset. Sunset/Twilight/Night switch the practical lights to their Night values.
- **Default now:** `ClockTime` 17.2 (AfternoonGoldenHour): warm low sun on the brick, street still clear. `Lighting` attributes: `DynamicLighting=true`, `MapPreset=Dynamic`, `LightingBand` = current band.
- **Switching:** in Play, set `game.Lighting.ClockTime = X` on the server and the band tweens over 3 s. From the command bar: `require(game.ServerStorage.MapTools.LightingPresets).apply("Dynamic", nil, 17.2)`, or `apply("Overcast")` / `apply("Night")` for the old static looks (those turn `DynamicLighting` off).
- **Backup:** `ServerStorage.MapTools.LightingBackup_20261017` (Lighting props as attributes, all children, Clouds, old LightingPresets). Untouched original kit: `ServerStorage.MapTools.DynamicLightingOriginal` (scripts disabled).
- **To do by hand:** `Lighting.Technology` was ShadowMap when the file loaded (`RBX_OriginalTechnologyOnFileLoad = 3`). The realistic screenshots need **Future**. Set it in the Properties panel.
- Tested in Play: start band AfternoonGoldenHour, 21 -> Twilight, 2 -> Night, back -> AfternoonGoldenHour. No new errors.

### Gritty retune (2026-10-17, Cade feedback)
Cade: the first pass looked "more vibrant and less hood like". Bands retuned for real shadows and heavy atmosphere:
- Day/golden/sunrise/sunset: ShadowSoftness 0.08-0.12 (crisp sun shadows), lower Ambient/OutdoorAmbient (shade is dark, not black), EnvironmentDiffuseScale 0.5.
- Atmosphere Density ~0.4, Offset 0.15, Haze 2.4-2.6, grey-brown color. Clouds Cover ~0.78, grey.
- Grade: Saturation -0.22 to -0.32, Contrast 0.2. Bloom threshold up to 1.5-1.6 so only bulbs glow.
- Default is now **ClockTime 15.5 (Day band)**: sun high enough that trees and poles throw shadows across the street, stormy grey sky.
- Night unchanged.
