---
type: ui
owner: flow
status: building
sources:
  []
updated: 2026-10-16
---

# HUD Ammo And Weapon Display

Branch of [[Gameplay HUD]]; source in [[04 Scripts/Gameplay HUD Source/Implementation]].

## Data contract
HUD reads local player attributes: `FPSWeaponId`, `FPSAmmo`, `FPSReserve`, `FPSReloading`, `FPSInspecting`, `FPSAiming`. The weapon controller publishes presentation values. These are UI state, **not server permission to shoot or deal damage**.

## Visuals and controls
- Bottom-right ammo uses a large handwritten magazine count and smaller reserve count.
- A separate ViewportFrame renders the actual selected weapon as a pale silhouette.
- Reloading/inspecting status appears beside the ammo.
- Custom slots use number keys **1–5**; the right-side inspect shortcut invokes `PlayerScripts.ReferenceFPSControl` when available.
- Small center reticle hides during ADS and sliding.
- `GrenadeCount` defaults to **0**. The icon does not mean grenade gameplay exists.

## Compatibility
Do not replace the controller with the earlier HUD integration file: [[Claude AK]] later added a `Controller.Shot` signal and custom firing effects. [[04 Scripts/Current Runtime Snapshot/Implementation]] preserves the current inspected source. Existing Compact AK sight and pistol presentation fixes remain documented in [[Weapon Build Archive]].
