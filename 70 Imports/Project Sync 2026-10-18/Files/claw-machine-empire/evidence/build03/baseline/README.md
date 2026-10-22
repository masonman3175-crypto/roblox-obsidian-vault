# Claw Machine Empire — Build 02: Toybox Arcade

The original playable loop is now inside a hand-authored, candy-colored arcade with **25 physically different claw cabinets**, studded construction and a decorated entrance lounge.

## Play in Studio

The confirmed **Place1** contains the installed build. Press Play, walk with WASD / the normal Roblox mobile controls, and approach a cabinet. Press **E** / its proximity prompt to use an owned machine or buy the next one with earned coins. **PLAY** also launches your currently selected owned cabinet from anywhere inside your own arcade.

- Aim with WASD/arrows or the four direction buttons. Press **Space / DROP**.
- Free plays: three stored, one refill per 12 seconds. No paid random catch path.
- Display catches in **PLUSHIES** to generate shelf-bank income; **COLLECT** moves it to your wallet.
- Unlock cabinets sequentially in **MACHINES**. Owned earlier cabinets remain selectable.
- Use **MAP VIEW** / **V** for the overhead gallery view; switch back to **WALK VIEW** to inspect the builds.
- Inventory: 40; shelf slots: 8. Stow and sell spares; discoveries remain in the index.
- Early alpha prices remain Rusty free, Classic $250 and Candy $600. Late-tier prices are initial tuning, not a claim of balanced retention.

## All 25 cabinet builds

Each cabinet has different authored geometry, not just a recolor. All use the same server-authoritative round system with their own configured prize pool and unlock price.

| # | Machine | Distinct construction |
|---|---|---|
| 01 | Rusty Claw | Crank, repair plates and roof bolts |
| 02 | Classic Arcade | Striped base, bulb marquee and score tower |
| 03 | Candy Cloud | Sculpted cloud crown and candy rails |
| 04 | Frog Pond | Giant eye crown and lily-pad step |
| 05 | Bunny Bloom | Tall ears, pink inserts and flower trim |
| 06 | Shark Splash | Dorsal fin, tooth awning and shark eyes |
| 07 | Lucky Cat | Angled cat ears, bell and whiskers |
| 08 | Honey Hive | Antennae, wings and bee-stripe cabinet |
| 09 | Dino Den | Spine, tail and snout details |
| 10 | Rocket Rally | Rocket tower, fins, nose and porthole |
| 11 | Cherry Soda | Can lid, straw, cherry and bubble motifs |
| 12 | Cosmic UFO | Oversized saucer and cockpit |
| 13 | Ocean Pearl | Fanned shell ribs and giant pearl |
| 14 | Treasure Chest | Rounded chest lid, gold straps and lock |
| 15 | Pixel Party | Stepped voxel crown and D-pad trim |
| 16 | Ice Palace | Crystal spires and icicle columns |
| 17 | Magma Forge | Twin chimneys, embers and lava cracks |
| 18 | Jungle Ruins | Stone lintel, vines and leaves |
| 19 | Rainbow Parade | Five-level rainbow crown and cloud trim |
| 20 | Golden Crown | Crown points, gold band and jewels |
| 21 | Diamond Vault | Rotated crystal, vault bars and lock |
| 22 | Galaxy Gate | Orbital ring and central planet |
| 23 | Cyber Circuit | Physical traces, nodes and antennae |
| 24 | Void Reactor | Segmented reactor ring and core |
| 25 | Infinity Carnival | Striped canopy, finials and infinity crest |

There are 25 original plushie species in the collection, with themed cabinet prize pools.

## Handbuilt environment

Five deliberately laid-out rows of five cabinets, 34-stud-deep aisles, 96 native-studded floor tiles, studded modular wall panels, 208 additional raised wall studs and raised floor-stud accents. Pink/lilac walls have white toy-brick columns and back-wall X braces. Native studs render across the full surfaces; the individual raised caps are additional physical detail.

Decorations include benches, potted topiaries, balloon bouquets and strings, original wall posters, ceiling light beams, gallery labels, a ticket counter/register, a part-built gumball dispenser, vending machine with drink cartons, giant duck/bunny podiums, display shelves and a collect terminal. The open ceiling keeps the map view usable.

The reference video is **Flamingo's ROBLOX +1 SPEED KEYBOARD ESCAPE**, not a claw-machine game. Its pastel studded rooms, oversized props and braced panels inform the art direction. Reviewed timestamps and interpretation are recorded in the Build 02 vault note. No video frames, meshes or game assets were imported into the game.

## Files and verification

- `Claw Machine Empire.rbxlx`: portable place; the world builds when Play starts.
- `INSTALL.luau`: generated installer for an empty ClawEmpire namespace; creates an Edit preview.
- `src/shared`: Config (25 cabinets and species), BigNumber, Economy.
- `src/server`: World, ProfileStore, Bootstrap.
- `src/client/Main.client.luau`: HUD, walking/map/aim cameras and inputs.
- `tests/contracts.luau`: actual Luau economic, persistence and 25-machine contracts.
- `tests/scene_build02.luau`: isolated ServerStorage scene fixture; checks geometry-only uniqueness, targets, claw placement, prompts and studs without changing player data.
- `evidence/build02/VERIFICATION.txt`: current evidence and remaining work. Build 01 evidence remains historical.

From this project folder:

```powershell
python tools/build.py
python tools/verify_build02.py baseline
python tools/verify_build02.py seal
python tools/verify_build02.py modified
python tools/verify_build02.py rollback --test
```

Run the generated `tests/RUN_IN_STUDIO.luau` in Edit Command Bar for the pure-module contracts. Run `tests/scene_build02.luau` in the Server context during Play for the isolated geometry fixture. A seal records known artifact hashes; do not reseal an unexplained change simply to make a verification pass.

## Studio data and purchases

Studio normally uses a session-only memory backend. To preserve the user's ongoing test across this rebuild, an **explicit developer snapshot** may be present in `ServerStorage.CME_StudioResume` with `Enabled=true`. It is consulted only in Studio and validated before loading. Subsequent test changes are in-memory; a new Play session returns to the stored snapshot. Disable/remove that folder to start fresh. It is not embedded in the portable place and is never consulted by published servers.

Outside Studio, the separate `ClawEmpire_Build01_v1` DataStore adapter retains schema compatibility, validates session ownership and serializes saves. A legacy profile with no `selected` field defaults to its highest owned machine. Live backend outage/rejoin tests and real multiplayer/physical-device performance validation still remain before release.

**Robux purchases remain disabled**, product IDs are zero and the shop is explicitly not for sale. The new world is not a live commerce release. No game was published.

## Roll back this change

Build 01 source files and the exact original packaged place are preserved under `evidence/build02/baseline`; hashes are in `BASELINE_SHA256.json`. This task's diff and rollback are separate from the older initial-install transaction.

`evidence/build02/ROLLBACK.sh --test` restores a separate temporary copy to Build 01, checks unrelated-file preservation and later-edit protection, and leaves the live Build 02 files changed. Without `--test`, it restores the guarded Build 01 project files; it does not operate Studio. Rebuild after an intentional project rollback to refresh generated manifests.

For the installed Studio scene, stop Play and run `evidence/build02/STUDIO_ROLLBACK.luau`. It restores the actual captured Build 01 containers from `ServerStorage.CME_Build01_Backup`. Keep that backup while you want this recovery option. The older root `STUDIO_ROLLBACK.luau` removes the entire game back to the original empty namespaces, not just Build 02.

## Next coding-robot prompt

```text
Continue the existing Build 02 Toybox Arcade. Read README.md, the Build 02
verification record and the linked Obsidian note. Keep all 25 distinct cabinet
models, native studded surfaces, authored decorations, legacy profile migration,
owned-machine selection, free plays and the Rusty/Classic loop working.
Improve one feature at a time. Keep rewards, IDs and wallet mutations server-owned.
Do not enable live purchases or publish as part of routine polish.
Rebuild generated files, run the Luau contracts and isolated scene checks,
play actual UI/proximity-prompt flows, check desktop/phone layouts, and record
observed results rather than describing fixture tests as real player progression.
```
