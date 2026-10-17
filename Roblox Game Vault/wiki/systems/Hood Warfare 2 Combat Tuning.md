---
type: reference
area: systems
owner: shared
status: idea
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, combat, weapons]
---

# Hood Warfare 2 Combat Tuning

## Verify before tuning

Record footage before claiming exact values for ADS speed, FOV shift, optic alignment, spread, recoil, recovery, camera kick, damage falloff, RPM, reload, sprint transitions, hit feedback, and audio.

## Original Roblox direction

- Use server-authoritative damage and ammo validation.
- Store per-weapon tuning in a shared config: damage, range, RPM, magazine, reload, ADS FOV, recoil, and spread.
- Keep the first-person viewmodel and animation smooth while replicating only necessary effects.

## How we'd build it in Roblox

- **Instances:** `Tool`s, `Attachment`s, `AnimationController`s, and viewmodel `Model`s in `ReplicatedStorage`.
- **Services / APIs:** `ServerScriptService` validates `RemoteEvent` payloads; `TweenService` and `RunService` drive client transitions.
- **Where it lives:** tuning in `ReplicatedStorage.Config.WeaponTuning`; damage in `ServerScriptService.Combat`.
- **Client vs server:** client predicts camera/viewmodel motion; server decides hits, damage, ammo, and cooldowns.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Weapon Lineup]]
- [[Color Grip Pistols Key Art]]
