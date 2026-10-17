---
type: weapon
owner: combat
status: shipped
sources:
  - raw/2026-10-16-gun-fp-impacts.png
  - Cade's beretta_m9_fbx.zip (Downloads, PBR textures included)
updated: 2026-10-17
---

# Claude Beretta

Beretta M9 in the **Silver 9mm slot (`W3`)**. The model came from Cade's download, the gloved hands are built by Claude, and it runs Claude's gun system (same as [[Claude AK]]). The feel is from [[First Person Gun Feel]].

## Model + rig
- Cade's M9 FBX was one mesh with 23 loose pieces. Claude split it into the parts the partner's controller animates:
  - `Bolt` = slide + decocker levers + rear sight (kicks back on every shot)
  - `Trigger` (pulls on fire)
  - `Magazine` = floorplate + an added hidden mag body (drops on reload)
  - `Body` = everything else
- Original PBR maps uploaded: color 82739317528017, normal 106524556418804, roughness 95211789569182, metal 127211492175668. They live in `ClaudeAK.Config.Beretta` and go on each part as `SurfaceAppearance`.
- Scale 2.2 studs per Blender unit (1.52 studs long, same as the old pistol). Root = grip center.
- Files: `Documents\HoodWarfare_Exports\Claude_Beretta.fbx` / `.blend`.
- Import gotchas:
  - The source FBX carried an empty animation take, so Roblox refused it. Export with `bake_anim=False`.
  - The gun parts got their transform applied twice in Blender. That was fixed in Studio by undoing the rotation and scale per part.

## Hands
- The partner's IK arms are hidden for guns with `CustomArms` (hook in `ReferenceWeapons.Controller`).
- **Style rule (Cade, 2026-10-17):** hands stay Roblox-blocky. They should just make sense, not look realistic. Realistic gloved finger meshes were tried and rejected ("noodles"). They're kept in `ServerStorage.ClaudeBerettaBackup_20261017.MeshHands`.
- Now: plain Parts per arm.
  - **Right:** a block hand that swallows the middle of the grip (grip top and bottom still show), tilted with the grip rake.
  - **Left:** a block hand cupping from the left.
  - Each arm has a forearm block running back toward the camera and a sleeve block over its back half.
- Colors: parts tagged `ArmPart = Skin/Sleeve` take the player's `EquippedHandColor` / `EquippedSleeveColor` (or BodyColors), painted by `ClaudeAKClient`.
- Reload: the mag drops and returns, the hands stay put. A real reload animation comes later.

## Feel (per-weapon numbers in `ClaudeAK.Config.Weapons.W3`)
- Semi-auto, 15 rounds, 1.9 s reload. Damage head 55 / body 25 / limb 20 (4 body shots), falloff to 60% from 60 to 220 studs.
- Hip hold is straight: `WeaponConfig` W3 `Hip = (.42, -.72, -1.5)`, yaw 3°. The old pistol pose was turned 22° and looked crooked.
- Recoil: climb 1.1° up per shot, stronger shake than the AK.
- **Muzzle:** star flash, short tongue of fire (VFX Studio flame texture), side flicker, sparks, smoke puff, light flash.
- **Screen fuzz:** the world blurs and pops brighter for a split second per shot. The gun stays sharp because it renders in the viewport GUI.
- **Dynamic crosshair:** opens per shot, with speed and in the air, and fades out when aiming. The HUD's static `AimMark` hides while a Claude gun is out.
- 9mm shells (smaller) eject right and up and clink on the ground.
- Sounds: shot 74125264456927 ("9mm gunshot"), reload 138248399002834 ("Pistol Reload (Tactical)", sped to match 1.9 s).

## Tested (2026-10-17)
- Equip, fire 8 shots, slide kick, smoke, shells, crosshair bloom, reload 7 -> 15 with sound, 4 body shots kill a dummy, no errors.

## Next
- Real reload animation (left hand to mag), sprint pose.
- Sound picks were made without listening. Swap the ids in `Config.Weapons.W3` if they're off.
- Third-person: the tool shows the gun only (no hands), welded to `WorldModel.Root`.

## Related
- [[Claude AK]] (same system, W1)
- [[First Person Gun Feel]]
- [[Weapon Lineup]]
- [[Blender MCP]]
