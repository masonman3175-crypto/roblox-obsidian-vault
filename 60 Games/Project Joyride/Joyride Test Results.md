# Joyride Test Results

Run 2026-10-25 in Studio solo playtest via MCP. Inputs injected with a test attribute (`JoyrideTestInput`) plus real key presses for R, F3, W. Numbers are from the live debug snapshot. Back to [[Project Joyride - Game Hub]].

| Test | Result | What was seen |
|---|---|---|
| T01 Launch | PASS | Auto-seated, Scriptable chase cam, no console errors |
| T02 Accel | PASS | 0 to 45 studs/s in 1.7s, 0 to 55 in 1.5s, smooth |
| T03 Low-speed turn | Not measured separately | Autopilot made tight turns at <25 studs/s fine |
| T04 High-speed turn | PASS | Half lock at 45-66 studs/s: steady 7 deg slip, stable |
| T05 Wide corner | PASS | Roll target ramps to 4.6 deg, actual follows with lag, holds while turning |
| T06 Corner exit | PASS | Roll eases 4.6 to 0 deg over ~1.5s, no snap |
| T07 Brake | PASS | Pitch target -4 deg, actual reaches -4.2 deg, front dips |
| T08 Accelerate | PASS | Front rises ~2 deg then settles to ~0.3 deg |
| T09 Drift entry | PASS | Slip 3.6 to 42 deg over 1.2s |
| T10 Drift exit | PASS | Slip 35 to 4 deg over ~0.9s after releasing Space |
| T11 Linked drifts | PASS | Roll goes -10 to +9 deg over ~0.9s continuously, no jump, speed kept 50-69 |
| T12 Steering visuals | Seen only | Front wheels turn in screenshots, not graphed |
| T13 Camera | Seen only | No jitter seen in screenshots, not judged in motion |
| T14 One dummy | PASS (indirect) | Every hit gave exactly +10, no doubles seen |
| T15 Dummy group | PASS | 11-dummy cluster: 6 and 7 hits in single passes, truck kept 75 studs/s |
| T16 Performance | Partial | 59-60 fps in debug overlay with 180 dummies, no long stress test |
| T17 Reset | PASS | R reset, still seated, drove to 52 studs/s with real W key |
| T18 Multiplayer | NOT TESTED | MCP playtest is single player only |
| T19 Respawn | Partial | Dummies respawn after timers, no connection leak audit done |
| T20 Anim graphs | PASS | F3 graphs show smooth target vs actual for roll, pitch, drift |

## V2 tests (2026-10-25, solo playtest, injected input)
| Test | Result | What was seen |
|---|---|---|
| Rapid accel | PASS | 0-30 in 0.45s, 0-60 in 1.4s, 0-90 in 2.1s (V1: 0-45 took 1.7s) |
| Max speed | PASS | 115 studs/s reached |
| Wide turn | PASS | Roll ~10.5 deg at 112 studs/s, half lock, holds |
| Corner recovery | PASS | Back to 0 in ~0.75s, tiny undershoot (-0.5 deg) |
| Drift | PASS | Slip to 48 deg; L to R switch rolls -17 to +19 deg smoothly; total speed kept ~110 |
| Camera accel | PASS | Distance 17 to 37, FOV 67 to 95, eases back on braking |
| Speed lines | PASS | Intensity 0 at rest, 1.0 above ~110, fades as speed drops |
| Tire marks | PASS | Two curved continuous trails seen in screenshots, pool counts rising and recycling |
| Single dummy | PASS | Instant launch from prediction, popup, burst |
| Horde | PASS | 11 of 13 dummies in one drift pass, group intensity 0.88, NICE! banner |
| Drift into horde | PASS | Slow-mo reached full blend once in that pass |
| Slow motion | PASS (by design) | Driving uses real dt, only cosmetics use TimeScale |
| Vehicle model | PASS | Blender mesh: curved fender flares, bevelled shell, wheel wells |
| Wheel animation | PASS | Front wheels steer and all 4 spin on the Blender wheels (screenshot) |
| UI | PASS | Custom fonts, score pill, speed bar |
| Audio | PASS | No custom sounds created |
| Multiplayer | NOT TESTED | Solo only. Slow-mo and TimeScale are local by design |
| Performance | PASS | 16.7 ms frames with Blender mesh, 180 dummies, skids |

Comparison vs V1: speed feel, steering, drift, lean and camera are all clearly bigger in the numbers. "Feels better" still needs Cade on a keyboard.

## Bugs found and fixed during testing
- Client read `PrimaryPart` before it streamed in: now waits for `Chassis`.
- Place has no PlayerModule: control disable now skips it after 5s.
- Truck stuck on the 1-stud SpawnLocation: added contact spheres, moved spawn to z=30.
- Hits never registered: OverlapParams uses Default collision group, which can't see DummyIdle. Added a `HitQuery` group.
- Dummies spawned half underground: pivot fixed with `PivotOffset`.
- Dummies barely left the ground: launch tuned (see [[Joyride Tuning Log]]).
