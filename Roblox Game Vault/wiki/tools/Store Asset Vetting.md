---
type: tool
area: tools
owner: shared
status: building
sources:
  - Map pass 4 car hunt (2026-10-16)
updated: 2026-10-16
tags: [tool, security, assets, store]
---

# Store Asset Vetting

Free Creator Store models are often reuploads with hidden scripts (backdoors that let someone else run code in our game). On 2026-10-16, 3 of 5 car models Claude inserted had them. This is the checklist. It applies to both devs and both AIs.

## What we found
| Asset | What was inside |
|---|---|
| 116549755605901 "French sedan" | 22 scripts named `PoseLink`, `Wave`, `Script`; model was 151 studs of junk |
| 84448302369434 "Realistic SUV" | 31 scripts + LocalScripts, 722 parts |
| 93702862785504 "Russian old car" | description said "No scripts", had `Runtime` (Script) + `ScreenBuilder` (LocalScript). Classic backdoor pattern. |

All deleted before any Play test, so nothing ran (scripts don't run in Edit mode).

## Checklist
1. Prefer older uploads from named creators (lower ids) over new keyword-spam reuploads ("Realistic RP Car Vehicle Ride Drive...").
2. Insert into an off-map staging folder, not into the map.
3. **List and delete every `Script`, `LocalScript`, `ModuleScript`** inside. Report the names.
4. Also remove stray `Camera`, `Seat`/`VehicleSeat` (or disable), `Weld`s to nothing.
5. Check size (world AABB) and part count. A "car" that's 150 studs or 700 parts is suspicious.
6. Screenshot it. Make sure it is what the title says (one "car" was a building).
7. Anchor everything, set collision, then move it into `ServerStorage.MapTools.PropMeshes` as a template.
8. Log it in [[Map Asset Registry]] with its id and creator.
9. After any insert, scan the whole game for new scripts outside our folders.

## Decals and images
- Look at every decal before using it. Reject brands, other games' IP, real people, gang names, hand signs, sets.
- Our own art (like the [[Graffiti Generator]] pieces) is safest.

## Hard rules (same as CLAUDE.md)
- No store weapons or characters. Ever.
- Delete all scripts inside inserted assets and report them.

## Related
- [[Map Asset Registry]]
- [[Studio MCP Gotchas]]
- [[index]]
