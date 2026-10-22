# Spawn, persistent character and glare fixes

Installed in ultimate slopp v1, place98823628319724, in Edit. The latest request's three fixes are implemented; no game publication was performed.

1. TimePlayedLeaderboard moved from the spawn origin to the back edge of the raised leaderboard plaza: bounding center X=-100,Z=31, bottom Y=4.55. It faces into the plaza and sits clear of the fountain and spawn. The editor-only thumbnail decal is hidden. Its existing scripts and settings are unchanged.
2. Dummy uses the provided Asian_Boy.blend character: nine persistent, textured MeshParts, scaled to4.6studs. The original Torso/PunchPrompt contract remains, with an invisible anchored Torso and no old visible block limbs. Native importer uploaded the mesh/texture assets; no EditableMesh runtime API dependency or settings change remains.
3. Bloom intensity1→0.14, size28→16, threshold1.2→1.8. Lighting brightness2.6→2.15 and exposure0→-0.12. SlopColor saturation0.35→0.16, contrast0.12→0.06. Hub lights halved; broad arena stripe, stand trims, screen and punch marker use SmoothPlastic. Color palettes and world geometry stay unchanged.

## Evidence and recovery
- MODIFIED_FILE.luau: guarded scene installer, requiring the persistent ServerStorage.PunchImportedVisual prototype. If absent, run tools/LOAD_CHARACTER.luau first to recreate it from the actual uploaded asset IDs.
- evidence/DIFF_FILE.diff: actual before/after scene manifest diff.
- evidence/VERIFICATION.txt: commands, literal results, test failures and corrections.
- evidence/ROLLBACK.sh: executable LOCAL manifest rollback, not a live Studio controller. --test restores only a disposable copy.
- evidence/STUDIO_ROLLBACK.luau: actual guarded Studio rollback; executed and verified, then fixes reinstalled. It restores original dummy, board placement, lighting and materials.
- baseline/scene.rbxm: engine-generated original scene component backup. Preserve ServerStorage.SpawnFixes_Backup for exact live rollback, including property target references.
- assets/character-assets.json: nine persistent mesh IDs with transforms and shared texture131826601705851. Original model file is unchanged; source SHA256 B1C9FD7BA4AA56464632F9610EFC2B6A2627125877D9397AA4EF5D7CB8F2374F.

Real Play-mode E punch passed:104ft,65coins, nine persistent client meshes, camera/control/prompt restored. Earlier temporary Edit-only opaque content did not replicate and was rejected; the final model uses uploaded asset URIs. Forty existing gameplay/board/other scene scripts and34,986track parts are unchanged. The six original worlds pass their geometry/appearance comparison.

Studio DataStore APIs remain disabled, so leaderboard live rankings and persistent profile saving are not verified. This task does not add the effects/audio/animation upgrade from the earlier interrupted request. No public game release was made.

## Coding robot prompt
```text
Preserve the completed spawn fixes, original worlds and economy. Use the persistent character asset URIs, never Edit-only opaque mesh content or a new EditableMesh runtime dependency. Keep Torso/PunchPrompt for PunchService and clone-safe CharacterVisual for PunchFx. Preserve the relocated board and reduced bloom. Back up changes, then verify actual client rendering, manual E punch/rewards, camera/prompt cleanup, all unchanged source hashes and rollback before claiming completion.
```
