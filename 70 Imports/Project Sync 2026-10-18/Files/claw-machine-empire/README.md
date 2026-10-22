# Claw Machine Empire - Build 03: Plushie Park

A much larger, handbuilt pastel arcade with 25 distinct claw machines, cinematic catches and a quiet cartoon HUD. Installed in the authorized Place1; no publishing was performed.

## Play

- Walk with normal Roblox controls (24-stud walking speed). Hold E at an owned cabinet, or use the single PLAY button.
- Aim with WASD/arrows or the four touch buttons. Space / DROP runs the crane sequence.
- The walking HUD has only a wallet, MY ARCADE and PLAY, plus one short context hint.
- MY ARCADE contains Plushies, Machines, Upgrades, income collection, bird's-eye map and reduced-motion controls.
- GO HERE travels only to an owned machine, selects it, and places you in front of its controls. V toggles map view.
- A catch opens one 3D reveal, not the full inventory. DISPLAY puts it on a shelf; KEEP IN BAG dismisses it.
- Three free plays, one refill every 12 seconds. Inventory 40, shelves 8. All 25 cabinets remain earnable.

## Requested changes

### Bigger map

The foundation increased from 142 x 204 to **300 x 440 studs**: 132,000 square studs, approximately **4.56 times** the former floor area. Five named districts have 52-stud cabinet spacing, 72-stud row spacing, 330 native-studded tiles, wide white/gold promenades, studded walls, white X braces, toy trees, flower gardens, benches, lamps, an entrance arch and a floating duck fountain. Original lounge props and the display/collect system remain. Plot spacing and authoritative interaction bounds were expanded together.

### Better animation

The 4.2-second server-driven crane sequence has anticipation, eased lowering, articulated three-finger closure, lift with a physically positioned prize model, carriage travel to the chute and release. A telescoping cable follows the carriage. Pure Config.clawPose determines cosmetics only; the server independently decides the catch and grants exactly once after the sequence.

Client-only orbiting sparkles, a gentle camera push, rotating sunburst, temporary confetti, springy card/button pops and a bobbing 3D original plushie create the reveal. Effects are cleaned up at the end of a round. Reduced motion suppresses optional motion and sparkles without changing outcomes. There is no camera shake.

### Simpler cartoon UI

Cream cards, pastel colors, chunky rounded borders and Fredoka type replace the former permanent title, three stat counters, tutorial box and four navigation buttons. Bank/rate, upgrades and collection live inside one menu. Claw controls appear only while aiming; default touch controls are hidden during our overlays/claw controls and restored afterward. Landscape reveal buttons retain native 46/44-pixel touch heights rather than shrinking the entire card.

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

## Files and tests

- Claw Machine Empire.rbxlx: portable source-complete place; the world is generated when Play starts.
- INSTALL.luau: generated Edit-mode installer for empty game namespaces.
- src/shared: Config, BigNumber, Economy.
- src/server: World, ProfileStore, Bootstrap.
- src/client/Main.client.luau: cartoon HUD, contextual inputs/cameras and local cosmetic effects.
- tests/RUN_IN_STUDIO.luau: generated pure Luau suite, 649 checks.
- tests/scene_build03.luau: isolated ServerStorage scene fixture, all 25 cabinet geometries, animated poses, target replacement, prompts and 330 studded tiles; no player grants.
- evidence/build03/VERIFICATION.txt: exact commands, results, screenshots, hashes and remaining validation.

```powershell
C:/Python314/python.exe tools/build.py
C:/Python314/python.exe tools/verify_build03.py baseline
C:/Python314/python.exe tools/verify_build03.py modified
C:/Python314/python.exe tools/verify_build03.py rollback --test
```

Run the generated pure tests in Studio Edit Command Bar and the scene fixture in Server context during Play. Rebuild after source edits. Only seal known reviewed artifact versions, not unexplained changes.

## Data and current demo

Schema 1, existing inventory/discovery, owned cabinets, selected cabinet and economy remain compatible. Studio uses session-only memory. An explicit, validated ServerStorage.CME_StudioResume snapshot preserves the ongoing demo across rebuilding; only Studio reads it. A new Play starts from that snapshot; subsequent changes are in memory. The snapshot is not embedded in the portable place. Published servers use the existing separate DataStore adapter.

Purchases remain disabled and product IDs remain zero. No paid random-catch path or checkout was added. Live persistence/outage/rejoin testing, real multiplayer, real-device performance and progression balance remain pre-release work. Studio device simulation is not physical-device certification. Existing Roblox CorePackages FoundationProvider/avatar-asset warnings are host messages, not an empty console claim.

## Recovery

Exact Build02 files and SHA256 hashes are under evidence/build03/baseline and BASELINE_SHA256.json. The unified diff is evidence/build03/DIFF_FILE.diff.

Run evidence/build03/ROLLBACK.sh --test in Git Bash to restore a disposable copy and check later-edit/unrelated-file guards. Without --test it restores the 16 guarded project files to Build02 and leaves unrelated files alone; it does not change Studio. Both modes preflight all hashes before writing. Restored Build02 has the previous smaller 96-tile arcade, old HUD and old crane motion.

To restore Studio, stop Play and run evidence/build03/STUDIO_ROLLBACK.luau. It clones the actual retained Build02 containers from ServerStorage.CME_Build02_Backup. This restore was tested and the new Build03 was reinstalled afterward. The older Build01 and initial-install recovery artifacts remain historical; the root STUDIO_ROLLBACK removes the entire game and is not the Build03 rollback.

## Reusable coding-robot prompt

```text
Continue Claw Machine Empire from the current src files and Build03 vault note.
Keep the walking HUD to wallet, one menu and one primary action. Keep the 25 distinct cabinets, free skill-based catches and compatible profiles. Inspect current Studio/local source before editing; snapshot any live demo progress before stopping Play. Preserve server reward authority and exactly-once grants. Optional animations must respect reduced motion and clean up all instances/connections. Keep the 300x440 studded park readable, not a floor full of HUD popups. Validate generated XML/source synchronization, 649+ pure contracts, all-25 scene choreography, catch/miss/replay, collection and phone touch targets. Keep recovery artifacts per build and verify restoration on a copy. Do not publish or enable purchases as part of visual polish.
```
