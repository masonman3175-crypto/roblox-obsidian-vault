---
type: system
owner: flow
status: building
sources: []
updated: 2026-10-17
---

# Sprint Slide And Map Boundary

User-requested gameplay follow-up to [[Main Menu And Locker]] and [[Hood Warfare 2 HUD and Presentation]]. The original pass below preserved spawn locations; the later [[Crouch And Compact Map]] update adds crouch, compacts the perimeter and relocates both pads safely.

## Controls and feel

- Hold **Shift** to sprint. **C / Left Ctrl / B** toggles crouch when not sprinting; **Shift+C/B** slides. Gamepad/touch controls remain.
- Press slide again during a slide to queue one follow-up. Each press queues one slide, not an automatic infinite loop.
- No extra cooldown after a slide finishes. The live test chained three slides with approximately 0.066 seconds between entries (network/frame handoff).
- Walking speed 14; sprint speed 24 studs/second.
- Slide speed starts at 36 and decays to 18 over .82 seconds. Minimum entry speed 10; direction follows existing momentum.
- Slide cost 4 stamina. Grounded sprint drains 5/second from 100: approximately **20 seconds**, previously 6.25. Regeneration is 25/second after a .45-second delay.
- Server still validates deployment, grounded state, momentum, stamina, input types and request rate. NaN direction and malformed sprint inputs were rejected.

## Lower camera and rig stability

The camera now smoothly lowers **1.45 studs through Humanoid.CameraOffset before Roblox's camera update**, rather than only applying a small transform afterward. Sprint/slide FOV and shake remain. Slide hip drop is .35 studs.

The first physics test exposed insufficient slide-constraint force against Humanoid braking. Increased bounded constraint force and retained nonzero slide WalkSpeed. The slide buffer retries until the server acknowledges the next slide.

Removed slide Motor6D.C0 manipulation to avoid automatic avatar-scaling feedback. Restore HipHeight and AutoRotate only when an active slide actually ends. Three-slide test retained the original R15 HipHeight (1.9980254) and restored CameraOffset essentially to zero; no cumulative sinking.

## Continuous perimeter

- **Workspace.Map.PerimeterBoundary**: four continuous colliding wall solids and decorative caps/seams/buttresses. The original four aprons were removed in the compact-floor update.
- Current inner playable limits: X -236 to 246, Z -122 to 122; original pass was X -262 to 272, Z -150 to 150.
- Walls span Y -14 to 84: **98 studs tall**, 8 studs thick.
- Continuous baseplate collision supports the compact perimeter; the earlier aprons were removed to eliminate coplanar floor overlays.
- Decorative parts are non-colliding; only wall solids and floor aprons affect movement.
- Added boundary proxies to the existing minimap.
- Current team pads: blue (-186,.9,-115), red (182,.7,108). Their original locations were preserved only in the earlier pass; see [[Crouch And Compact Map]].

## Verification and restore

- 840 perimeter ray samples at six heights: zero gaps.
- Actual avatar sprint into the east wall stopped at X 271.4254, inside inner face X 272, with grounded state true.
- Actual sprint reached 24 studs/second; three consecutive slides; camera offset minimum -1.4500; peak measured shake about 1.75 degrees; correct height/offset restoration.
- Invalid remote payload checks pass. No movement-script errors in the tested console.
- Temporary QA floor existed only during Play and was removed when Play ended.
- Exact baseline modules: ServerStorage.MovementBoundaryBackup_20261016. Restore logic tested against isolated clones, preserving the live modifications.
- Source mirrors, hashes, test scripts and full commands: [[04 Scripts/Movement And Boundary Source/Implementation|Movement And Boundary Source]].
- Current game changes are in the Studio Edit DataModel. Let Team Create save and commit any Studio drafts before partner testing; no public publish claimed.

Related: [[Main Menu And Locker]], [[Main Street Routes and Cover]], [[2026-10-16]].

## Later 2026-10-17 follow-up
- [[Crouch And Compact Map]] is the current control/geometry specification: crouch speed 8, 1.55-stud eye drop, safe headroom, 27% smaller boundary, corrected floor overlaps and 5% music. Historical 2026-10-16 test figures above remain dated evidence.

## Current co-op lobby movement
- [[Lobby Movement And Queue Circles]] permits existing sprint/slide/crouch in the physical lobby. Server-owned InLobby overrides only movement menu gating; weapon authority remains gated and tools stashed.
- Shift sprint24, sprint+C slide; V/button first/third person works in both lobby and deployed play. Stamina, ground/momentum, crouch/headroom and malformed-payload validation remain.
- Controlled live lobby sprint/slide/standing recovery passed; initial live client slide showed camera dip. Main-map walls/geometry are unchanged.
