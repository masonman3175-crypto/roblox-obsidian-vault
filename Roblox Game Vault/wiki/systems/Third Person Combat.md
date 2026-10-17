---
type: system
owner: combat
status: shipped
sources:
  - Cade feedback screenshot 2026-10-17 (gun pointing up, crosshair on head, free mouse)
updated: 2026-10-17
---

# Third Person Combat

**Cade's call (2026-10-17):** the game is third person only. First person and the V toggle are gone.

## Camera (`StarterPlayerScripts.ClaudeThirdPerson`)
- Over-the-shoulder: the camera shifts 2.1 studs right and 0.55 up, so the crosshair sits beside your head, not on it. The offset pulls in when a wall is on your right.
- Fixed distance 8 studs (set in `LobbySystem.Client`).
- In a match: mouse locked to center, cursor hidden, character turns with the camera (shift-lock style, `RotationType.CameraRelative`). In the lobby the mouse is free so you can click the queue UI.
- Runs at `RenderPriority.Last + 2`, after the default camera, the gun controller and the lobby script.

## Aim pose
- Every armed character raises both arms toward where its player is looking:
  - **Waist:** 35% of the pitch.
  - **Neck:** 40% of the pitch.
  - **Right arm:** forward.
  - **Left arm:** crosses in to support the gun.
- Set on the joint `Transform` in `RunService.Stepped`, after animations. Works with the avatar's AnimationConstraint joints.
- Pitch sync: the client sends `ClaudeAK.AimPitch` 10x a second, and only when the pitch changed. The server clamps it to ±75° and stores it in the player attribute `AimPitch`. Every client poses every player from that.
- Tool `Grip` = identity on all 5 guns, so the barrel points along the raised arm. The old grip made guns point at the sky.

## Shooting
- Aim point = camera ray through the crosshair (with spread).
- The bullet ray goes from the head toward that point, and the server checks the origin is within 7 studs of the head.
- Muzzle flash, tracer, barrel smoke and shells come from the gun in your hands (`WorldModel.Root.Muzzle`), not the hidden first-person model.
- Screen fuzz is half strength in third person.
- All 5 guns run Claude's system now (W2 Compact AK, W4 Lime 9mm, W5 Pump Shotgun added). The shotgun fires 8 server-side pellets with 4.5° spread, and damage is summed per target into one hit marker.

## Partner code touched
- `LobbySystem.Client`: third forced on, V key and CAM button removed, zoom 8/8, no longer forces the mouse free.
- `WeaponConfig`: `CustomFx` on W2/W4/W5.
- Backups in `ServerStorage.ClaudeThirdPersonBackup_20261017`.

## Tested
- Shoulder cam, mouse lock, arms up, gun pointing forward (checked on a local clone), and firing the Beretta in third person: flash at the gun, crosshair bloom, no errors.
- **Not tested:** server damage inside a real 2-player match. Duos/Trios queues need 2+ players, so the lobby strips tools from a solo test.

## Related
- [[Claude AK]]
- [[Claude Beretta]]
- [[Zombie Lobby And Co-op Queues]]
