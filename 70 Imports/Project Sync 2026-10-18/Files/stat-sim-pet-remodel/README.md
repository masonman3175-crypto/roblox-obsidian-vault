# Pet & Egg Remodel — installed in Studio
## Delivered
- All 63 original pet IDs now have native-part cube creatures with glossy oval eyes, tiny paws, smiles and species-specific features.
- 10 oversized companions, approximately 11–22 studs across: GoldenGorilla, CandyHydra, FrostTitan, ThreeHeadedDragon, DemonKing, VoidTitan, CosmicGod, GalaxyLeviathan, InfinityDragon and GoldenCerberus.
- 11 mystery-egg palettes: stepped studded shells, two question-mark badges, branching luminous seams, wooden nests, floating shards, orbit arcs, sparks and rising motes.
- Pet bobbing, wing flaps, moving halos; eggs hover and orbit. Giant companions use separate size-aware rows behind smaller pets.
- All 85 emitter instances use outward surface emission, not emission buried inside a giant body. Per-pet rates are 3–9/s; each egg totals 11/s. Distant emitters are disabled.
- Inventory/hatch pet previews are normalized to 3 studs with particle emission disabled. Giant cards are marked HUGE.

## Preserved
Pet IDs, powers, rarities, hatch probabilities, Lucky behavior, prices, inventories, slot limits, passes, receipts and server purchase logic. All 35 unrelated existing scripts are unchanged. Six original worlds and all appended track geometry remain; 34,986 track parts and the imported nine-mesh punch character remain. Global Bloom stays 0.14.

## Files
- MODIFIED_FILE.luau: complete self-contained EDIT installer containing the eight source modules. The original ServerStorage.PetRemodel_Backup must exist; do not run it in a different place.
- DIFF_FILE.diff: five changed modules and three added modules.
- VERIFICATION.txt: exact test commands and observed engine/play results.
- ROLLBACK.sh: executable LOCAL source-copy rollback / self-test, not an automatic Studio connection.
- tools/ROLLBACK_STUDIO.luau: returns rollback(root, backup). For the actual Studio Edit scene use the function with game and game.ServerStorage.PetRemodel_Backup. This restores the original five source modules, ten original custom models and removes the eleven egg previews.
- baseline/scene.rbxm: serialized original backup, before installing the remodel.
- evidence/installed-scene.json: actual installed source hashes and visual coverage.
- evidence/pets-and-eggs.jpg, pets-gallery.jpg, massive-pets.jpg, inventory.jpg: actual Studio/play screenshots. Galleries are QA showcases, not new areas left in the playable map.

## Verify locally (PowerShell, this directory)
~~~powershell
& C:\Python314\python.exe -X utf8 tools/check.py baseline
& C:\Python314\python.exe -X utf8 tools/check.py verify
& 'C:\Program Files\Git\bin\bash.exe' ./ROLLBACK.sh --test
~~~
The bash self-test restores a disposable source copy, preserves an unrelated marker and checks that the working sources stay modified. Studio rollback was separately exercised on an isolated scene fixture, including executing the restored old factory and confirming all 63 pets return to its original 3-stud size policy.

## Studio tests
Run tests/MODIFIED.luau in Edit. Run tests/PLAY_PARTICLES.luau on the Client after starting Play. PLAY_SERVER_BRIDGE and PLAY_CLIENT_BRIDGE are temporary QA harnesses only; they are NOT installed in the saved Edit scene. No test inventory or giant test pets were added permanently.

## Next-agent brief
~~~text
Continue the existing pet/egg remodel in ultimate slopp v1. Read this README and VERIFICATION.txt. Preserve all original pet IDs, powers, rarity tables, prices, Lucky odds, receipt handling, original worlds, punch character and reduced Bloom. Change appearance in PetDesigns, PetModelBuilder, EggVisual or the visual controllers only. Keep preview sizes normalized, giant formations non-colliding, and particles surface-emitted with distance limits. Compile sources before installation, refresh prefabs, run the Edit and Client tests, and retain a verified rollback copy.
~~~

Final state: installed in Edit and ready for normal playtesting. No publish operation was performed. Existing Studio API-access datastore warnings remain; this task did not change security settings.

