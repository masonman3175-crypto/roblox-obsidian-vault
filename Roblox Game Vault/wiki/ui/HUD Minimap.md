---
type: ui
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# HUD Minimap

Part of [[Gameplay HUD]]. Top-left circular `ViewportFrame` uses its own Camera and a simplified `WorldModel`, not a static copy of the reference screenshot.

## Map source
`ReplicatedStorage.GameplayPresentation.MinimapWorld` stores proxies for ground, alleys, roofs, parked cars and tree canopies. Initial builder produced 597 parts. Eight boundary proxies were added later; read-only Studio inspection during this sync counted **605 children**. The builder in [[04 Scripts/Gameplay HUD Source/Implementation]] is the historical 597-part pass; the boundary builder lives in [[04 Scripts/Movement And Boundary Source/Implementation]]. Re-run both only deliberately, never duplicate their output blindly.

## Behavior
- Camera follows the local character and camera heading; update interval is about .06 seconds.
- Center marker shows the player; cyan teammate markers require the same non-neutral team.
- No enemy wall tracking is implemented by this HUD.
- Config uses `MinimapHeight=155`, `MinimapFov=70`.
- A proxy is not a collision wall. Physical containment is [[Sprint Slide And Map Boundary]].

## Maintenance
Map owner changes may require rebuilding the proxy. Use `Workspace.Map` only as a read source. Keep minimap models free of scripts, physics and collision, and review cost on low-end devices. See [[Map Asset Registry]].
