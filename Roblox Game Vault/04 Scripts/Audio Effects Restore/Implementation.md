# Audio Effects Restore Implementation

Current overview: [[Game Audio And Music]], [[Crouch And Compact Map]], [[2026-10-17]].

- MODIFIED_FILE.luau: effects-only repair installer, with final Client/Config sources embedded. Run only through Studio MCP in Edit after inspecting live state. It guards against replacing an existing task backup.
- BASELINE.json: pre-repair sources/assets/mix metadata; original package clones in ServerStorage.AudioSfxRestoreBackup_20261017.
- Client.luau / Config.luau: final source mirrors, 12 effect assets; no music IDs, player, button or F8 toggle.
- DIFF_FILE.md / VERIFICATION.txt / TEST_RESULTS.json / CONSOLE.txt: exact changes, commands/results, runtime and known unrelated messages.
- TEST_*: weapon/reload, movement-idle, cancellation, teardown/restart, validation and isolated rollback test inputs.
- RESTORE.luau: returns a restoration function with optional explicit isolated targets. Normal default targets live package/mix; restores original broken music dependency, not a functioning music-free system.
- ROLLBACK.sh: executable helper. --self-test checks separate local bytes only; default prints Studio restore instructions.
- Source archive is not a published place or an automatic live sync. Use current live code; do not overwrite collaborator combat changes with historical snapshots.
