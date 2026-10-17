---
type: weapon
owner: combat
status: shipped
sources:
  - raw/2026-10-16-fps-reference.png
  - raw/2026-10-16-weapon-kit-reference.png
  - raw/2026-10-16-gun-fp-impacts.png
updated: 2026-10-16
---

# Claude AK

Claude's AK replaces the partner's Walnut AK (`W1`). His other four guns, arms, HUD, ADS and reload animations are unchanged. His guns are the "nerf" set; this is the real-feel AK. Built from [[First Person Gun Feel]] and [[Weapon Lineup]].

## Model (Blender, v2)
v1 looked like a toy (flat slabs, flat colors). v2 follows the refs:
- **From [[Weapon Lineup]]:** black blued steel with silver edge wear, visible rivets and trigger pins with the retaining spring, black polymer grip, polymer **waffle mag** (raised grid, recessed squares, reinforced top bands).
- **From the FPS ref:** classic AK wood furniture.

Build:
- Real AKM proportions in mm, converted at 0.0034 studs per mm. Blender origin = pistol grip center = viewmodel `Root`. Barrel points Blender +Y (Roblox -Z).
- Rounded parts are lofted cross-sections, not flat extrusions: handguards with palm-swell ledges, a tapered stock, an egg-shaped grip, a curved mag with a floorplate.
- Hard parts are beveled: slant brake, front sight with hood ears, gas block with vents, ribbed dust cover, rear sight leaf + slider, trunnions, mag-well dimple, selector, charging knob, bent trigger guard, sling loops, buttplate with screws.
- 8 meshes, about 18k triangles, named `W1__<Component>__<Material>__0` so the partner's controller animates them (Body, Bolt = carrier + charging handle, Magazine, Trigger).

**Textures:** baked in Cycles from procedural shaders. Bevel-node normals make every edge look rounded.
| Set | Size | Maps | Look |
|---|---|---|---|
| Steel | 2048 | color, normal, rough, metal | blued, worn silver edges + patches |
| Wood | 1024 | color, normal, rough | dark reddish walnut, fine grain |
| Polymer | 2048 | color, normal, rough | near-black, stippled, scuffed edges |

- Uploaded ids live in `ClaudeAK.Config.Surfaces`. They go on each MeshPart as `SurfaceAppearance`.
- Files: `Documents\HoodWarfare_Exports\Claude_AK47.fbx`, `.blend`, `AK_Textures\*.png`. Generator scripts were scratch Python (loft + superellipse/rounded-rect rings, bake pipeline).
- Studio can't save meshes built by script (EditableMesh is memory-only), so Cade imports the FBX once. Then Claude swaps the meshes into `ReplicatedStorage.ReferenceWeapons.Viewmodels.W1` and the `StarterPack.Walnut AK` WorldModel.

## Firing feel (client, visuals only)
`StarterPlayerScripts.ClaudeAKClient` + `ReplicatedStorage.ClaudeAK.Fx`:
- **Muzzle flash:** star core, forward cone, side flicker, sparks, thin haze, 0.05 s PointLight that lights the street.
- **Smoke:** one faint puff per shot. Barrel smoke wisps after bursts of 5+ (heat builds per shot, cools 6/s).
- **Shells:** brass casings eject right and up from the port, inherit your movement, spin, bounce on the ground with a clink. Max 30, gone after 4 s.
- **Tracers:** short streak moving 900 studs/s.
- **Impacts:** dust tinted by the surface color, falling chips, sparks on metal and glass, bullet hole plus faint ring (max 120, 20 s), impact sound. Player hits get a small grey puff only (no blood).
- **Recoil:** partner's spring kick is stronger for W1 (`Kick .068`, `CameraRecoil .85`). On top of that a climb of 0.42° up and ±0.22° sideways per shot that eases in over a few frames, plus camera shake. Aiming cuts both by 30%.
- **Hit marker:** white = hit, yellow = headshot, red and bigger = kill.
- **Other players' shots:** flash at their gun's `Muzzle` attachment, tracer, impact, 3D gunshot sound, shell.

## Server (authority)
`ServerScriptService.ClaudeAKServer` (thin) + `.Logic`:
- `ClaudeAK.Shoot` (origin, direction). Checks: finite vectors, unit direction, alive, AK equipped, origin within 7 studs of the head (otherwise uses the head), fire rate (80% of 600 RPM), a 30-round mag with a 1.6 s reload gap tracked on the server.
- Server raycast up to 600 studs. Passes through invisible non-solid parts. Damage Head 70 / Body 30 / Limb 24, falls off to 70% between 120 and 400 studs. `Humanoid:TakeDamage` respects ForceFields. Teammates are skipped when teams exist.
- `HitConfirm` goes to the shooter, `Replicate` goes to everyone else.
- Tested: 4 body shots kill a dummy, hit markers arrive, no errors.

## Numbers live in
`ReplicatedStorage.ClaudeAK.Config`: RPM, mag, damage, falloff, spread (hip 1.6°, ADS 0.25°), climb, sound and texture ids.

## Partner code touched (minimal)
- `ReferenceWeapons.Controller`: added a `Controller.Shot` signal. Guns with `CustomFx` fire it instead of the stock effects.
- `ReferenceWeapons.WeaponConfig`: W1 recoil numbers + `CustomFx = 'ClaudeAK'`.
- Backups of W1, Controller, WeaponConfig and the tool: `ServerStorage.ClaudeAKBackup_20261016`.

## Sounds (store, free, all load)
- Shot 1112730119
- Shell 6850980505
- Impacts 79671891898982 and 131554175554758

## Installed (2026-10-16)
- Cade imported the FBX (it came in at 100x and turned 180°). Claude scaled it, flipped it, and rebuilt `Viewmodels.W1` (anchored) and the `Walnut AK` tool `WorldModel` (welded to Root). Each part has `SurfaceAppearance` from `Config.Surfaces`. The raw import is in `ServerStorage.ClaudeAKBackup_20261016`.
- WeaponConfig W1: Muzzle (0, .323, -2.319), Aim (0, .49, -.544), Bolt (.112, .371, -.435), Magazine (0, -.017, -.476).
- Tested in play: equips, 8 meshes, fires, holes and shells, textures show.

## Next
- Tune ADS sight alignment and left-hand spot on the new handguard by eye.
- Real bullet-hole decal texture, reload sounds, distant-shot sound layer.

## Related
- [[First Person Gun Feel]]
- [[Weapon Lineup]]
- [[Map VFX Library]]
- [[VFX Studio]]
- [[Blender MCP]]
