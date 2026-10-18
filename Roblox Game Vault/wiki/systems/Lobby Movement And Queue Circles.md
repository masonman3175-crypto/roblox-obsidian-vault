---
type: system
owner: flow
status: shipped
sources: []
updated: 2026-10-17
---

# Lobby Movement And Queue Circles

Follow-up to [[Zombie Lobby And Co-op Queues]], [[Sprint Slide And Map Boundary]] and [[Game Audio And Music]].

## Current controls and view
- Lobby now supports the existing server-authoritative sprint, slide and crouch system. Shift sprints at 24; C while sprinting slides. Stamina, ground, speed and payload checks stay active.
- V or the camera button switches first/third person in lobby and deployed play. Default third person: Classic camera, zoom7-20, visible avatar, first-person viewmodel hidden locally.
- Camera reconciliation survives the existing weapon initialization requesting first person. Combat/controller source remains untouched.
- Old top title/status banner is removed, not hidden behind another panel. Only a contextual queue panel and small controls remain.
- M still returns to the unarmed lobby. Music remains absent.

## Eight reference-style circles
- Two independent queues per Solos/Duos/Trios/Squads: Mode_1 and Mode_2, eight circles total.
- Radius7, rowsZ=-9/+9; no overlapping membership areas. Platforms/light columns are non-colliding and walk-through.
- Outlined floating player count and 15-second timer echo the user reference. Counts/timers are per-circle; full groups only start countdown. Row label heights are staggered for readability.
- Public QueuedMode retains the friendly mode; QueuedQueueId/CoopQueueId identify the specific circle.
- Server membership uses circular radial distance. Two partial circles never pool together. Leave/step-out/reset is independent per circle.
- Everyone remains Survivors and deploys at the same (0,4.6,0) arena transform.

## Verified
- Actual fresh Play:8 circles,2 per mode, no banner; real V first/third and M return.
- Actual live circle switching, radial corner exclusion, sprint-out cancellation, second Solo circle deployment and real Leave click.
- Deployed third-person avatar27 visible parts, first-person overlay hidden, one W1 shot cue; V restores native first-person view.
- Controlled live movement: sprint24, real slide hip drop, stamina use and restored standing HipHeight1.9980254.
- Pure kernel:8 simultaneous full groups/20 unique members, independent duplicate-mode timers and cancellation, no duplicate dispatch. This is not a live20-client test.
- 232 circle-floor rays, non-overlap checks, five exact live-source matches, unchanged Queue kernel and actual isolated rollback.

## Evidence and remaining work
- [[04 Scripts/Lobby Movement And Queue Circles/Implementation|Sources, exact inputs/results and rollback]].
- Backup: ServerStorage.LobbyMovementEightQueuesBackup_20261017. Baseline4 queues/banner/movement gates restore on isolated copies; live update retained.
- User image was actually viewed; it was not uploaded or imported as an asset. Interactive circles use native Instances, no imported scripts.
- Real simultaneous multi-client departure and comprehensive third-person aiming/touch/gamepad remain acceptance work. Commit Studio drafts.

## Later third-person and animation update — 2026-10-17
[[Third Person Combat]] supersedes the V-toggle/camera-button instructions above: the game is now third-person only. [[Slide Animation And Two-Handed Hold]] adds actual rig-compatible slide/crouch poses and repairs premature client-owned slide cancellation. Eight queue circles remain unchanged.

## Latest camera and queue rules
[[Private Sessions And Zombie Opening]] adds lobby left/right drag orbit and changes departures to nonempty10-second snapshots/private sessions. Current combat zoom6.2/4.2; V remains retired. Old15s/full-group checks above are historical.
