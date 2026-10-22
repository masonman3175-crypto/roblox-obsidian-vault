---
kind: game-build
game: claw-machine-empire
build: 03
status: implemented-and-playtested
tags: [roblox, claw-empire, animation, map, cartoon-ui]
---

# Build 03 - Plushie Park

User direction: make the animations much cooler, the map much bigger, and the UI more cartoony and far less busy.

## Implemented

- 300 x 440-stud map, approximately 4.56x the previous floor area (142 x 204). All 25 separately authored machines remain.
- Five spacious named districts, 330 native-studded tiles, white/gold promenades, braced pastel stud walls, toy gardens/trees, lamps, entrance arch, giant mascots, a floating duck fountain and collector pavilion. The display lounge, counter, vending machine and other handmade props remain.
- 4.2-second crane choreography: anticipation, eased descent, articulated three-finger grip, plushie lift, carriage travel, chute release and reset. Cable length changes with the crane.
- Local sparkles, slight camera push, springy button/card pops, temporary confetti, rotating sunburst and bobbing/spinning 3D prize preview. Reduced motion suppresses optional motion. Cosmetic effects do not grant rewards.
- A quiet walking HUD: wallet, MY ARCADE, PLAY and one short context hint. The prior permanent title, navigation stack, tutorial, bank/rate counters are removed from the walking view.
- One menu contains inventory, collection, earned-coin upgrades, bank collection, machine travel, overview and reduced motion. A catch offers DISPLAY or KEEP, not an automatic inventory popup.
- Owned-machine fast travel is server validated; 24-stud walking speed suits the larger map. Schema, earlier owned machines and inventory remain compatible.

## Screenshots

![[CME Build 03 - Simple Walking HUD.jpg]]
![[CME Build 03 - Arcade Plaza.jpg]]
![[CME Build 03 - One Arcade Menu.jpg]]
![[CME Build 03 - Articulated Claw Lift.jpg]]
![[CME Build 03 - 3D Prize Reveal.jpg]]
![[CME Build 03 - Phone Landscape.jpg]]
![[CME Build 03 - Phone Portrait.jpg]]

## Verification

- Baseline Build02: 389 actual Luau contract checks.
- Build03: 649 actual Luau checks, including progression, weighted pools, profile faults, expanded bounds and deterministic animation envelopes.
- Actual isolated Studio scene test: 25 unique geometry signatures, target/claw/prompt checks, 200 sampled animated poses, 330 studded tiles and cleanup. It does not grant player items.
- Live catch, no early grant, duplicate-drop replay, corner miss, reveal cleanup, immediate display, owned machine travel, physical E prompt, actual menu collection, movement restoration and source synchronization were tested.
- iPhone 17 Pro simulator: landscape reveal retains 46/44-pixel buttons within the safe canvas; portrait wallet/menu/play fit; default touch controls restore after the overlay. This is simulation, not a real-device performance certification. Device simulation was returned to default landscape.
- Exact file hashes and a disposable-copy rollback test accompany the build. Actual Studio Build02 restoration was tested, its 389 checks were rerun, and Build03 was reinstalled.
- Existing Roblox CorePackages FoundationProvider/avatar-asset warnings remain host messages. No game-source error appeared in the final console capture.

[Full verification](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/evidence/build03/VERIFICATION.txt) | [Portable place](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/Claw%20Machine%20Empire.rbxlx) | [README](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/README.md)

## Recovery and demo data

Build03 recovery uses evidence/build03/ROLLBACK.sh and STUDIO_ROLLBACK.luau; it restores Build02, not the original empty place. The prior build and hashes are retained. A Studio-only validated developer snapshot preserves the ongoing demo across restarts; later Play changes remain in memory. The portable file has no personal snapshot.

Purchases remain disabled; no publication occurred. Next release work is live persistence/outage/rejoin, real multiplayer/device performance and balance. None of those are claimed complete by this visual pass.

## Reusable coding-robot handoff

```text
Continue from current Build03 source and README. Preserve the small three-group walking HUD and contextual controls. Preserve the 300x440 studded park, 25 distinct cabinets, free skill-based catches and compatible profiles. Inspect and back up current Studio progress before restarting. Keep reward authority on the server and cosmetic effects local, bounded, cleaned up and reduced-motion-aware. Run the pure contract suite, all-cabinet scene choreography, catch/miss/replay, collection, source/XML sync and phone bounds checks. Add per-build recovery evidence and test restoration on a copy. Do not enable purchases or publish as part of visual changes.
```

## Connections

[[Claw Machine Empire - Game Hub]] | [[Claw Machine Empire - Build 02 Toybox Arcade]] | [[Claw Machine Empire - Visual Direction]] | [[Original Game Design]] | [[Collectible lifecycle state machine]] | [[Persistence is part of gameplay]] | [[Regression suite organized by invariant]]
