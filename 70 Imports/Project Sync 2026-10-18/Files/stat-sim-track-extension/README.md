# Original worlds + landscape extension

Installed in the authorized **ultimate slopp v1** Studio place (98823628319724). This corrects the rejected compact replacement: the old worlds are the real original instances restored from the engine backup, not newly approximated worlds.

## What stays
Grass Fields, Desert, Snow Mountains, Volcano, Candy Land, Outer Space, all their geometry, colors, meshes, signs and original distance mapping. The Hub, training islands, pets, shop, economy and persistence sources stay unchanged. Only two of the original 29 scripts change: Punch track mapping and PunchFx streaming integration / Motor6D type check.

## What is added
60 named 1,000-stud landscape worlds after Outer Space: 66 total, plus subsequent deterministic frontier variants. They clone the original landscape building blocks and add terrain-scale landmarks, rather than replacing the style with toy platforms. Jungle Falls, Redrock Badlands, Aurora Glaciers, Crystal Caverns, Ringworld Frontier and other themes mix original scenery with waterfalls, canyon arches, glacier blades, ancient ruins, forests and space outposts.

The obsolete Finish barrier is removed; its original is retained in ServerStorage. The original Outer Space BackdropEnd becomes transparent, with matching panels framing an opening. No other original biome geometry or visual properties change.

## Runtime
Editor: all 60 appended worlds appear under Map.Track.ExtensionsPreview. Play: only that preview folder is removed, while the original six remain. The client streams appended scenery around flight focus and preloads the destination and following world. Extra-world budget: 8. Tested stages: 7, 8, 12, 66, 67, 126 and 1000. There is no catalog-length distance clamp, but ordinary floating-point/Roblox coordinate limits still apply; this is not literal mathematical infinity. The fixed original flight timing is preserved.

Original track mapping stays identical through 10 million feet; after that, ten new 1,000-stud worlds fit each additional distance decade. Reward formulas are unchanged.

## Files and checks
- MODIFIED_FILE.luau: guarded Edit installer; supports reinstallation after rollback.
- evidence/DIFF_FILE.diff: full source diff against the original 29 scripts.
- evidence/VERIFICATION.txt: exact commands, observed results, rollback and remaining test boundaries.
- evidence/ROLLBACK.sh: executable local source rollback; --test restores only a disposable copy.
- evidence/STUDIO_ROLLBACK.luau: separate guarded Studio scene/source rollback.
- baseline/EngineBackup.rbxm: original engine-generated Track and scripts backup; SHA-256 568b309ae9cdcf7232a858c5d2523532e70d1356d4127fdecbce0bab6afe3dc2.

Build: C:\Python314\python.exe tools/build.py
Local validation: C:\Python314\python.exe tools/build.py verify
Rollback self-test: ./evidence/ROLLBACK.sh --test
Studio tests: execute tests/baseline.luau, tests/RUN_IN_STUDIO.luau, tests/originals.luau and tests/scene.luau in Edit. tests/runtime.client.luau is a temporary Play-mode LocalScript harness; it was removed after testing, not shipped as gameplay code.

Studio backup folders are retained, including the rejected replacement for recovery. Installation changes the open Edit place; no publishing operation was performed. DataStore persistence was not tested because this place has Studio API access disabled. Existing asset-type warnings were present; no new TrackExtension/PunchFx errors remained in the final Play session. Mobile performance and multiplayer load are not measured.

## Prompt for the coding robot

    Continue the append-only Stat Sim track extension. Read this README and the source diff first. Preserve the six original Map.Track biome folders, Hub, original distance mapping, economy and all unrelated systems. Add new worlds only after Outer Space. Match the original full landscape scale, ground strips, meshes, arches and signs; use new terrain-scale landmarks, not toy dioramas. Keep streamed extra worlds within the configured budget. Back up before changing anything, then run original-geometry, scene, contract, manual-punch/camera and rollback checks. Never overwrite the imported Obsidian source snapshot.
