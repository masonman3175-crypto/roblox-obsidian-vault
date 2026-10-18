---
type: system
owner: flow
status: building
sources:
  - raw/2026-10-17-private-session-research.md
  - raw/2026-10-17-slide-and-aim-reference.md
  - https://create.roblox.com/docs/projects/teleport
updated: 2026-10-17
---

# Private Sessions And Zombie Opening

Latest direction supersedes the15-second/full-party/shared-spawn behavior in [[Zombie Lobby And Co-op Queues]] and [[Lobby Movement And Queue Circles]]. Builds on [[Slide Animation And Two-Handed Hold]] and [[Third Person Combat]].
User explicitly approved bounded firing and zombie-combat edits.

## Shipped in the editable Studio place
- Eight circles still cap parties at1/2/3/4. First occupant starts10seconds; additions/removals do not reset a nonempty circle's deadline. Exactly the eligible occupants at zero leave together; empty circles cancel and no dispatch duplicates.
- Lobby left/right mouse-drag orbit, wheel zoom, right-stick and right-side touch look. GUI clicks remain GUI clicks.
- Third-person gun visibility no longer depends on a later script undoing a first-person hide; normal/aimed zoom6.2/4.2 and shoulder1.65/.30 show the held gun more clearly.
- Crouch no longer lowers physical HipHeight into the floor. Procedural root/hip/knee pose lowers the head about.775stud, plus camera.6; floor-aware correction preserves visible feet.
- Tap-only trigger edges replace held automatic repeat. Small white aim circle blooms slightly; dedicated circular touch FIRE uses one Activated event, controller R2 uses begin/end.
- Personal furnished houses have distinct owner ids and slots.12-second intro: lying in bed, animated wake/get-up, decoded outside crash, walk to window, camera reveal of infected, then exactly one W3 pistol. Front-door prompt validates owner/distance/phase and exits at the assigned map porch.
- Eight initial street infected: own first-party R15 rig with correctly baked upgraded joints, dark hood/drawstrings/pocket, red eyes and motes. Client shamble/attack/flinch/death poses; server-owned pathing, timed melee with fresh range/LOS check, server ray damage and ZombieKills attribution. This is an opening encounter, not completed waves/progression/persistence.

## Private-server handoff — implemented, live acceptance pending
ServerScriptService.SurvivalRun.Transport creates a reserved allocation and stores an expiring server-side MemoryStore manifest. TeleportAsync targets the reserved id with the immutable party snapshot; clients receive no access code or membership-authority payload. Destination validates PlaceId, roster, duplicates/size, expiry and UserId before starting a run. Nonmembers are rejected. Retries reuse the same allocation; failure/timeouts restore usable lobby state.
Current Studio reflection exposes ReserveServerAsync and ReservedServerId; official release743 notes newer allocation migration. Actual allocation/teleport compatibility must be accepted against the published server build. Do not claim live teleport success from these Studio tests.
Studio explicitly uses a labelled local intro preview and limits it to one active party. It is not a private server.

## How we'd build it in Roblox
- ReplicatedStorage.SurvivalRun: Config, Client cinematic/NPC animation/objective UI, LobbyCamera.
- ServerScriptService.SurvivalRun: Service lifecycle/houses/NPCs, Transport manifest/teleport, World reusable room/hood construction.
- StarterPlayerScripts.SurvivalRun is a thin client bootstrap. LobbySystem.Service starts the server modules and routes arrivals/departures.
- Existing validated ClaudeAKServer.Logic still decides hits/damage. Added menu/cutscene guards, payload arity check and server-only NPC credit tags; damage configuration remains unchanged.
- Native bed source119702734710201 and native generated R15 rig live in ServerStorage.SurvivalBedAsset/SurvivalZombieRig. Four imported/generated script containers removed (see raw record). No store guns/characters or guessed animation IDs.
- ServerStorage.PrivateZombieSessionBackup_20261017 holds12 originals; source contract was absent and not fabricated.

## Verified
- Actual left mouse down/move changed orbit yaw/pitch; GUI processing respected.
- One real player in Duos_2 starts10s and launches a partial party; all stable-deadline/capacity/leave-at-zero/duplicate-circle cases pass on fresh kernel clones.
-26 intro samples show all5 stages; actual bed/window views inspected; crash/groan IsLoaded=true; final intro completed at12.06749s with W3 only and controls restored.
- Four real house geometry fixtures have distinct owners/positions and no embedded scripts; not four connected players.
- Tap hold test15->14 over.7s, repeat press blocked, next fresh tap13;13px reticle.
- Controlled existing server Shoot remote kills a registered infected: ZombieKills0->1 and LastDamageUserId correct. Controlled melee100->88; wall window stays88. Temporary QA input/regen/anchors restored.
- Return removes own house/actors and leaves an unfrozen lobby.18 final sources match UTF-8 fingerprints;12 backups. Isolated full install/rollback restores all12 original strings and all8 labels to15s, deletes7 new sources/two new assets, leaves live update intact. Executable local-copy rollback exit0.
- Existing cloud/CoreUI/asset203785492 warnings remain. Earlier user-interrupted/streaming test attempts were diagnostics, excluded from passes.

## Remaining acceptance
Publish/commit Studio drafts, then verify actual private handoff, same-circle2/3/4-client arrivals and unique house slots, nonmember rejection, real disconnect/teleport failure recovery and returning to a public lobby. Touch/gamepad hardware, varied avatar/terrain/headroom and network/performance acceptance remain. No public publish claimed.

## Evidence
[[04 Scripts/Private Sessions And Zombie Opening/VERIFICATION.txt]] has exact commands/inputs/literal outputs/statuses, baseline/final hashes, final18 sources and rollback. [[04 Scripts/Private Sessions And Zombie Opening/BUILD_ASSETS.luau]] documents asset reconstruction. RESTORE.luau restores sources/15s labels and removes new package/assets; live game stays changed.

## Reusable follow-up prompt
```text
Read the latest session logs and Private Sessions And Zombie Opening. Preserve the new10-second snapshot queues, tap-only input, pistol-only house intro and server-authoritative zombie damage. Verify published-client reserved-server API compatibility and real2/3/4-player roster/house assignment first. Do not treat Studio preview as private transport; preserve ownership, original backups and test evidence, then commit drafts and sync notes.
```
