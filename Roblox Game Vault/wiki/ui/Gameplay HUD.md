---
type: ui
owner: flow
status: building
sources:
  - raw/2026-10-16-handwritten-hud-reference.png
updated: 2026-10-16
---

# Gameplay HUD

![[2026-10-16-handwritten-hud-reference.png]]

## Reference breakdown
The supplied screenshot places a large circular map at top left, tilted dark red/blue score strips and a small timer at bottom left, a tiny central reticle, a weapon silhouette plus handwritten ammo at bottom right, and small squad/emote-style buttons along the right edge. Gameplay occupies most of the screen. The warm street scene is a reference, not our map or an imported background.

## Built presentation
`ReplicatedStorage.GameplayPresentation.HUD` builds `ReferenceGameplayHUD`. The thin `StarterPlayerScripts.GameplayPresentation` boot starts movement and HUD. Font is **IndieFlower**, the closest chosen handwriting style; the screenshot's exact font remains **unverified**, and the user did not know its name.

- [[HUD Minimap]]: circular live proxy map with teammate markers.
- [[HUD Ammo And Weapon Display]]: actual ammo/reserve, weapon silhouette, reload/inspect status and crosshair.
- [[HUD Scores And Feed]]: red/blue scores, clock, warmup and server-fed elimination rows.
- Stamina/state display reads the movement system; the sprint bar now lasts about 20 seconds from full. [[Sprint Slide And Map Boundary]] is the authoritative tuning note.
- Layout scales with camera viewport. HUD hides in the menu. Default backpack/player list are hidden in favor of custom controls.

## How we'd build it in Roblox
Use `ScreenGui`, Frames/TextLabels/UIStroke, `UIScale`, circular clipping and two `ViewportFrame`s with Cameras/WorldModels. `RunService` updates presentation after the camera. `ContextActionService` handles slots. Server-owned match state and validated combat events supply scores/feed; UI never grants damage or rewards.

Source: [[04 Scripts/Gameplay HUD Source/Implementation]]. Current read-only export: [[04 Scripts/Current Runtime Snapshot/Implementation]]. No new game edits or runtime playtest occurred during this vault-only sync.
