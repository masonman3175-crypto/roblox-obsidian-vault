# Lobby Movement And Queue Circles Implementation

Overview: [[Lobby Movement And Queue Circles]], [[Zombie Lobby And Co-op Queues]], [[Sprint Slide And Map Boundary]].

- MODIFIED_FILE.luau is a complete guarded Edit installer with five final module sources plus final circle builder embedded.
- Config/LobbyClient/LobbyService/MovementClient/MovementService.luau mirror the five changed modules.
- BUILD_QUEUES.luau builds only the queue subtree: 8 independent circles, 2 per mode, floating count/timer labels. Original lobby map/leaderboard remain.
- BASELINE.json preserves original six inspected modules; Queue kernel is unchanged. Original scene plus five changed sources backed up in ServerStorage.LobbyMovementEightQueuesBackup_20261017.
- TEST_* / TEST_RESULTS.json / VERIFICATION.txt record actual baseline, live checks, pure multi-group cases, corrections and limitations.
- RESTORE.luau returns a function with optional isolated target roots. Actual isolated restore tested source equality and the old 4-gate subtree; live eight-circle update retained.
- ROLLBACK.sh is executable; --self-test checks only local byte restoration on separate temp files. Normal mode prints Studio instructions.
- Previous [[04 Scripts/Zombie Lobby And Co-op Queues/Implementation|first lobby installer]] is a historical baseline, not the current queue/movement setup. Source mirrors do not publish Roblox.
