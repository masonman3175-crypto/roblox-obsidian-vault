---
type: reference
area: ui
owner: shared
status: idea
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, ui, hud, presentation]
---

# Hood Warfare 2 HUD and Presentation

## Study targets

Observe HUD placement, inventory flow, objective messaging, score notifications, kill feed, hit markers, respawn protection, phone or streak screens, and mobile/controller readability. Treat all exact behavior as `(unverified)` until footage confirms it.

## How we'd build it in Roblox

- **Instances:** `ScreenGui`, `Frame`, `TextLabel`, `ImageLabel`, `UIGradient`, and an accessibility-friendly crosshair layer.
- **Services / APIs:** `TweenService` for feedback, `UserInputService` for input, and `ContextActionService` for mobile/controller bindings.
- **Where it lives:** client HUD in `StarterGui` and `StarterPlayerScripts`; server sends validated score and objective state through `ReplicatedStorage.Remotes`.
- **Client vs server:** client renders presentation; server owns score, kills, objectives, and match timers.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Art Direction]]
- [[Weapon Lineup]]
