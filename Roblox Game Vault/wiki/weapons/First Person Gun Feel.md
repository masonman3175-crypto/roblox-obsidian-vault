---
type: reference
area: weapons
owner: combat
status: idea
sources:
  - raw/2026-10-16-gun-fp-eotech-rifle.webp\n  - raw/2026-10-16-gun-fp-impacts.png\n  - raw/2026-10-16-gun-fp-blood-decals.png\n  - raw/2026-10-16-gun-third-person-hold.png
updated: 2026-10-16
tags: [reference, weapon, first-person]
---

# First Person Gun Feel

![[2026-10-16-gun-fp-eotech-rifle.webp]]
![[2026-10-16-gun-fp-impacts.png]]
![[2026-10-16-gun-third-person-hold.png]]

## What it is
Roblox FPS clips: a rifle with a holographic sight held low-right in first person, an SMG firing into a wall with muzzle flash and bullet holes, and a third-person crouch holding an SMG with both hands.

## Breakdown
- Viewmodel sits low and right, big in frame, barrel angled slightly in. Detailed PBR gun, simple arms.
- Muzzle flash is a quick bright puff plus haze, not a big sprite.
- Bullet holes stay on the wall as small dark decals with a dust puff.
- Hit feedback: thin crosshair hit-marker ticks.
- Third person: two-handed hold, gun follows the aim, crouch pose.
- (unverified) The blood splats and decals in the impact clip break our content rules (no gore or blood). Use sparks and dust only.

## How we'd build it in Roblox
- **Viewmodel:** client `Model` welded to the camera each `RenderStepped`, with sway and bob springs. Arms + gun as MeshParts.
- **Impacts:** client raycast for visuals only (the server decides hits). `Decal` on a tiny part at `RaycastResult.Position`, oriented to `Normal`, cleaned up with `Debris`. Material-based puff: brick dust, concrete chips, metal sparks.
- **Muzzle:** `ParticleEmitter:Emit()` + a 0.05 s `PointLight` on the muzzle `Attachment`.
- **Third person:** `Animator` animations for hold, aim and crouch, with the gun welded to the RightHand.
- **Where:** COMBAT client modules (per the contract). Our gun owner is partner + Codex right now.

## Related
- [[Weapon Lineup]]
- [[Map VFX Library]]
- [[index]]
