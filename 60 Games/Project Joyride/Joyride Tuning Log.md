# Joyride Tuning Log

All values live in `ReplicatedStorage.Joyride.Config`. Back to [[Project Joyride - Game Hub]].

## Initial values
Spec values used as is: max speed 75/25, accel 48, brake 78, coast 9, reverse 28, grip 7 / drift 2.2, drift entry 7 / exit 4.5, drift min speed 14, drift steer x1.25, roll 7 / 10 deg, pitch 2.5 / 4 deg, suspension 0.025 / 0.08 / 0.18, steer visual 28 deg, camera 19 back / 10 up, FOV 70 to 79.

Added (not in spec): yaw rate 2.5 rad/s low speed to 1.35 high speed, grip redirect 0.45, anti-spin above 48 deg slip, drift entry kick 0.55 rad/s, roll damping 0.72, suspension damping 0.45.

## Changes
| Date | Value | From | To | Why |
|---|---|---|---|---|
| 2026-10-25 | Collider bottom | 0 | 1.2 + 4 contact spheres | Flat box could not climb the 1-stud SpawnLocation |
| 2026-10-25 | Spawn origin | 0,0,0 | 0,0,30 | Clear of SpawnLocation |
| 2026-10-25 | Dummy MinUp / MaxUp | 12 / 26 | 18 / 34 | Arc was ~2 studs high under Roblox gravity |
| 2026-10-25 | Dummy gravity scale | 0.85 | 0.3 | Floaty cartoon arc, about 1s airtime |
| 2026-10-25 | Dummy air drag | none | 0.9 /s | Fast hits flew off screen |
| 2026-10-25 | Dummy inherit velocity | none | 0.6 | At 75 studs/s the truck caught up to dummies launched at 55 |

## Not tuned yet
Steering feel by hand, camera drift lag, roll reference accel (75). Needs Cade driving with a keyboard.
