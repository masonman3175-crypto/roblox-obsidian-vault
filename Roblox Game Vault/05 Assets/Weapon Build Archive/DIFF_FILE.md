# Reference-Guided Weapon Rebuild

Changed field: active scene -> `Reference_Rebuild_Studio` (a new scene in a new .blend copy).
Original file: `C:\Users\mason\OneDrive\Desktop\Roblox AI\weapon_pack_final.blend`
Original SHA256: `756C82A4242274CD5F06C33C9B9A183F8B7E5723D93C4B9604A76D5DD6231BA5`

## Structural difference
- Baseline active scene: 157 objects, 141 mesh objects, 3,780 base polygons, no armature.
- Rebuilt weapon geometry: 388 individually bound mesh components, 24,011 base polygons, 172,436 evaluated triangles across all five weapons.
- New rigs: five armatures, six bones each; 20 named animation clips (Fire, Reload, Equip, Inspect per gun).
- Added pinned, packed references from the actual three inspected photo files. Original scene remains available in the new file; original file is unchanged.

## Reference-guided models
1. Walnut AK: shaped walnut buttstock and handguards, rounded dust cover, curved detachable magazine, open circular front sight, receiver rivets, selector, bolt handle, open trigger guard, hollow barrel and muzzle brake.
2. Compact AK: shorter silhouette, skeleton stock, ribbed rail, curved magazine, rounded black handguards and textured grip.
3. Silver 9mm: beveled slide, real cutout ejection port, visible barrel, hollow muzzle crown, angled/scalloped rubber grip, open guard and sights.
4. Lime Tactical 9mm: black slide, reference-style green grip, stippling and finger scallops, separate slide and magazine, underbarrel light.
5. Satin Pump Shotgun: long hollow barrel, tubular magazine, sculpted ribbed pump, skeleton stock, shell carrier and sight rib.

## Animation and export
- Meshes have rigid bone weights. Reload drops magazines, cycles bolts, or works the shotgun pump. Fire moves bolts and trigger; Equip and Inspect move the root.
- Bone axes verified so magazine removal travels downwards, not sideways.
- Five individual FBX files were reimported into fresh test scenes; each retained its mesh count, skeleton and four named clips.
- Metallic/rubber/wood shader appearance is authored in Blender. Procedural shader detail is not baked to Roblox texture maps in this pass; FBX includes basic materials.

## Boundaries of this change
- No map, spawn, Studio combat scripts or existing live tools were edited in this pass.
- These rebuilt models and clips are local Blender/FBX assets; the older in-game prototypes have not yet been replaced with them.
- This pass contains weapon rigs, not a newly authored arm/hand animation rig.
- Rollback restores the byte-identical legacy .blend into a separate explicit target. The live rebuilt deliverable remains changed.
