# Zombie Lobby And Co-op Queues Implementation

Current overview: [[Zombie Lobby And Co-op Queues]], [[Game Audio And Music]], [[Main Street Block]].

- MODIFIED_FILE.luau: complete fresh-baseline installer with final source and scene embedded. Guarded by ServerStorage.ZombieLobbyBackup_20261017; never re-run it over an existing current backup.
- BUILD_LOBBY.luau: isolated compact scene builder using copies of existing map assets; all copied script descendants stripped (0 found). It does not replace main map geometry.
- Config/Client/Service/Queue.luau: exact final live lobby sources. Queue kernel is pure and independently tested.
- AudioClientIntegration.luau / AUDIO_ORIGINAL.luau: complete final/original audio source. Only two gating clauses differ, allowing lobby movement audio without returning music.
- BASELINE.json / DIFF_FILE.md / VERIFICATION.txt / TEST_RESULTS.json / TEST_*: original sources, changes and exact results.
- RESTORE.luau: returns the restoration function; optional explicit environment supports actual isolated rollback tests.
- ROLLBACK.sh: executable local-byte self-test plus Studio restoration instructions. It does not control Studio directly.
- This is a same-server co-op lobby, not cross-server matchmaking, zombie AI/waves or a published Roblox place. Commit Studio drafts before partner testing.
