---
type: system
owner: flow
status: building
sources: []
updated: 2026-10-16
---

# Movement And Boundary Source

Source mirror for [[Sprint Slide And Map Boundary]], in hood warfare 1.2.

| File | Destination |
|---|---|
| MODIFIED_FILE.luau | ReplicatedStorage.GameplayPresentation.MovementClient |
| MovementConfig.luau | ReplicatedStorage.GameplayPresentation.MovementConfig |
| MovementMath.luau | ReplicatedStorage.GameplayPresentation.MovementMath (unchanged dependency) |
| MovementServer.luau | ServerScriptService.GameplayMovement.Service |
| BuildBoundary.luau | Edit-time builder for Workspace.Map.PerimeterBoundary and minimap proxies |

The existing GameplayPresentation client boot, MovementRequest RemoteEvent, HUD and server boot remain. This folder is a source/test mirror, not a complete place file.

## Verification

From this directory:
- `python verify.py BASELINE` -> BASELINE: PASS (original conditions recorded).
- `python verify.py MODIFIED` -> MODIFIED: PASS (new source and hash checks).
- `./ROLLBACK.sh rollback-copy.luau` -> ROLLBACK: PASS (separate local source-copy fixture only).

HASHES.json preserves baseline and changed file hashes. DIFF_FILE.patch covers the three changed modules and the new perimeter builder. VERIFICATION.txt records exact commands, input, literal results, runtime physics and geometry checks.

PhysicsTest.luau runs in the Client during Play, after clicking PLAY. Its temporary server fixture is a Part named MovementTestFloor, size (360,2,90), at (0,139,0), anchored; player's ReplicationFocus points to it while streaming. The test streams it, then positions its test avatar on top and overrides movement input briefly. Only run in a development Play session. Release ReplicationFocus afterward and stop Play to remove the fixture.

GeometryTest.luau runs in Edit. WallPhysicsTest.luau runs in Client during Play with the EastSolid region streamed.

## Restore

- restore_studio.luau is the real Edit-mode rollback: restores the exact three baseline ModuleScript Sources from ServerStorage.MovementBoundaryBackup_20261016; removes the added perimeter and its minimap proxies.
- RollbackFixtureTest.luau runs that exact restore against isolated cloned services and a spawn sentinel, without undoing the live changes.
- ROLLBACK.sh only restores a local client-source copy and refuses to overwrite MODIFIED_FILE.luau.

Related: [[Sprint Slide And Map Boundary]], [[08 AI Workflow/Session Logs/2026-10-16-codex|Codex session log]].
