# Keyboard System

## Purpose
Make keyboard keys react when the player walks over them.

## Inputs
- `Players.LocalPlayer.Character`
- `HumanoidRootPart.AssemblyLinearVelocity`
- Keycaps inside the overlap filter

## Outputs
- Keycap movement using `BulkMoveTo`
- Random pooled sound playback
- Smooth press/release animation

## Configuration
| Name | Value |
|---|---:|
| `BASE_DETECTION_SIZE` | `Vector3.new(2.5, 5, 2.5)` |
| `LERP_SPEED_DOWN` | `20` |
| `LERP_SPEED_UP` | `8` |
| `HOLD_TIME` | `0.15` |
| `VELOCITY_PADDING` | `1.2` |
| `SOUND_COOLDOWN` | `0.03` |
| `PRESS_DEPTH` | `1.4` |

## Related
- [[04 Scripts/KeyBoardSystem]]
- [[05 Assets/Audio Assets]]
- [[03 Nodes/Workspace Nodes]]
