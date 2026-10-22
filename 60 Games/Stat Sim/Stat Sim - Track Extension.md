---
tags: [game/stat-sim, roblox, implementation, append-only]
status: installed-in-studio
updated: 2026-10-18
---
# Stat Sim — keep the originals, extend the track

The six original worlds are restored: **Grass Fields → Desert → Snow Mountains → Volcano → Candy Land → Outer Space**. The original landscape scale, scenery, meshes, arches, signs and first-six distance mapping stay intact. The old end barrier opens into 60 appended 1,000-stud worlds, making 66 named worlds total; later frontier variants continue without a catalog-length cap.

## Visual direction
Use the original full landscapes, not the rejected toy-diorama replacement. New worlds clone the original building blocks and add terrain-scale landmarks: Jungle Falls, Redrock Badlands, Aurora Glaciers, Crystal Caverns, Ringworld Frontier, cherry valleys, redwoods, mushroom marshes, fossil plateaus and more.

![[Track Extension - Original Grass.jpg]]
![[Track Extension - Jungle Falls.jpg]]
![[Track Extension - Aurora Glaciers.jpg]]

## Implementation
- Original six remain in Map.Track; only the obsolete Finish barrier and the original space end-wall visibility change.
- ExtensionsPreview contains the appended editor worlds. Runtime removes only those previews and streams appended scenery with an eight-world budget; originals are never streamed away by this system.
- Two existing scripts changed, four added. Rewards, pets, shop, Hub, training islands and persistence scripts remain unchanged.
- Original progression remains unchanged through 10M feet; subsequent decades each span ten new worlds.
- Deterministic frontier variants follow world66; ordinary numeric/coordinate limits still apply.

## Verification
502 contract checks passed. Geometry comparison preserves all 3,531 original biome descendants and original distance boards. All 60 appended scenes have contiguous ground and lane-clear landmarks. Real E-input punch: 137ft, 80coins; camera, dummy and prompt restored. Streaming tests passed at stages7,8,12,66,67,126,1000 (maximum observed five extra worlds). Both local-copy and actual Studio rollback passed; extension reinstalled afterward. No new extension/PunchFx errors remained. DataStore persistence, mobile frame rate and multiplayer load were not tested.

## Project and recovery
[Local project](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/stat-sim-track-extension/README.md) · [Verification](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/stat-sim-track-extension/evidence/VERIFICATION.txt) · [Installer](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/stat-sim-track-extension/MODIFIED_FILE.luau) · [Studio rollback](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/stat-sim-track-extension/evidence/STUDIO_ROLLBACK.luau)

Original engine backup and source hashes are retained. Historical import notes and sources are unchanged. The change is installed in the open Studio place, not published.

## Coding robot prompt
```text
Extend Stat Sim append-only. Preserve the six original biome folders, Hub, original distance mapping and unrelated game systems. Match the original large landscape style; add new natural landmarks after Outer Space. Read the project README and DIFF_FILE.diff first. Keep streamed extra worlds within eight. Back up changes; verify original geometry, contiguous new ground, real punch/camera behavior and rollback. Never replace the original worlds or overwrite the imported Obsidian source snapshot.
```

## Related
[[Stat Sim Punch Track]] · [[00 Hub]]
