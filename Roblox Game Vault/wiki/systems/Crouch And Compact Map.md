---
type: system
owner: flow
status: shipped
sources: []
updated: 2026-10-17
---

# Crouch And Compact Map

Follow-up to [[Sprint Slide And Map Boundary]], [[Game Audio And Music]] and [[Main Street Block]], requested after the user's 2.90-second screen recording.

## Current controls and camera
- C / Left Ctrl / gamepad B: toggle crouch while not sprinting. Shift+C/B while sprinting: slide. Repeated slide input still queues a follow-up.
- Crouch movement speed: 8 studs/sec, versus 14 walk and 24 sprint.
- Server lowers HipHeight by .60; camera smoothly offsets .95 lower before Roblox's camera step. Actual measured eye drop: 1.55 studs (5.30566 -> 3.75566).
- Additive R15 hip/knee/ankle/waist pose, applied after animation and removed before the next animation step. No Motor6D.C0 scaling manipulation.
- Server validates action type/arity, deployment, grounded entry and request budget. Low ceilings prevent standing; sprint stands only with clearance.
- Death/automatic respawn and returning to menu from active crouch both clear stance/camera. Existing weapon presentation follows the lowered camera without weapon source edits.

## Quieter music
- Default lowered from 25% to **5%** in AudioPresentation.Config and SoundService.BackgroundMusic.
- Fivefold lower linear gain (approximately -14 dB from the old default).
- Existing F8 and clickable mute remain; the label now displays 5%.

## Compact perimeter
- Current inner bounds: X[-236,246], Z[-122,122], flush with measured outer building extents.
- Inner footprint: 482 x 244, versus 534 x 300 previously. Area reduced 26.5868%.
- Existing wall solids and architectural detailing moved/resized, with matching minimap proxies. Buildings and internal routes unchanged.
- Both existing team-only pads moved inside: blue (-186,.9,-115), red (182,.7,108). Both actual deployments passed; still opposite corners and retain protection.

## Floor repair
- Video frames 1/4/6 actually inspected, not inferred from its filename.
- Found 12 broad coplanar pairs: four border apron/baseplate, seven tile/soil, one road patch/patch.
- Removed redundant aprons, lowered baseplate top .16, separated tile support/top, clipped pavement around curbs/soil and hid one duplicate patch.
- Tile pieces 455 -> 500. Broad coplanar audit now finds zero pairs. This audit does not cover every tiny paint mark or all facade/shadow aliasing.
- Ground collision remains continuous; 242 spawn-floor samples and 900 wall rays pass.

## Verification
- Six crouch/stand cycles: HipHeight 1.9980254 before/after, camera returned to zero.
- Actual speeds: crouch 8, sprint 24. Chained slides retained, slide offset -1.43237, with camera/hip recovery.
- Crouched ADS/fire/reload passed; existing weapon code untouched.
- Real low-roof obstruction blocked standing, then released after removal.
- Malformed crouch, NaN slide direction and extra remote arguments rejected.
- Both actual team spawns, active-crouch death/respawn and active-crouch menu reset passed.
- Five modified source mirrors and three unchanged inspected sources match live state.
- Isolated rollback restored original geometry fingerprints/source strings and 25% music on clones; live fix retained.

## Evidence / handoff
- [[04 Scripts/Crouch And Compact Map/Implementation|Implementation, source mirrors and exact tests]].
- Studio backup: ServerStorage.CrouchCompactFloorBackup_20261017.
- Unrelated concurrent Workspace.Dynamic Lighting lighting scripts log missing ReplicatedStorage Lighting System, and Cloud placement/count messages. Left to map owner; no unrelated lighting edits.
- Simultaneous multiplayer posture/footstep observation not tested.
- Studio ended in Edit. Let Team Create save and commit Studio drafts before partner testing. No public publish performed.