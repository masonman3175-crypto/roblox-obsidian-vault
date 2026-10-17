---
type: weapon
owner: combat
status: building
sources:
  - raw/2026-10-16-fps-reference.png
  - raw/2026-10-16-weapon-kit-reference.png
  - raw/2026-10-16-gun-fp-impacts.png
updated: 2026-10-16
---

# Claude AK

Claude's AK replaces the partner's Walnut AK (`W1`). His other four guns, arms, HUD, ADS and reload animations are unchanged. His guns are the "nerf" set; this is the real-feel AK. Built from [[First Person Gun Feel]] and [[Weapon Lineup]].

## Model (Blender)
- Classic AKM: black stamped receiver, walnut handguards and stock, dark grip, ribbed curved steel mag, slant brake, front sight tower, gas block and tube, rear sight leaf, charging handle and selector on the right, rivets, trigger guard, cleaning rod, buttplate.
- 9 meshes, about 4.3k faces, named `W1__<Component>__<Material>__0` so the partner's controller animates them (Body, Bolt = charging handle, Magazine, Trigger) and his wraps recolor the wood.
- Scale: 0.0034 studs per mm. Blender origin = pistol grip center = viewmodel `Root`. Barrel points Blender +Y (Roblox -Z).
- Files: `C:\Users\cadesyl\Documents\HoodWarfare_Exports\Claude_AK47.fbx` and `.blend`. Build scripts were throwaway Python (helpers: profile extrude, box, cylinder).
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

## Next
- Swap in the Blender meshes after Cade's import. Update `Muzzle (0, .323, -2.319)`, `Aim (0, .5, -.6)`, `Bolt (.1, .364, -.435)` in WeaponConfig.
- Real bullet-hole decal texture, reload sounds, distant-shot sound layer.

## Related
- [[First Person Gun Feel]]
- [[Weapon Lineup]]
- [[Map VFX Library]]
- [[VFX Studio]]
- [[Blender MCP]]
