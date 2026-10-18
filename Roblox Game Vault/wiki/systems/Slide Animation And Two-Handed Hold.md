---
type: system
owner: flow
status: shipped
sources:
  - raw/2026-10-17-slide-and-aim-reference.md
  - https://create.roblox.com/docs/physics/constraints/animation
  - https://github.com/Roblox/creator-docs/blob/main/content/en-us/reference/engine/classes/AnimationConstraint.yaml
updated: 2026-10-17
---

# Slide Animation And Two-Handed Hold

Works with [[Third Person Combat]], [[Sprint Slide And Map Boundary]] and [[Lobby Movement And Queue Circles]] in hood warfare1.2. User explicitly approved a bounded combat pose/grip integration; firing/damage untouched.

## What changed
- Existing movement only lowered HipHeight; old crouch pose rejected the actual avatar's AnimationConstraint joints. New client CharacterPose supports R15 AnimationConstraint and Motor6D, with bent-leg slide entry, asymmetric seated glide and recovery. It uses procedural Transform animation, not an uploaded animation asset.
- Server ground probe now retains the original standing range during lowering. A normal client-owned character previously lost ground detection and cancelled as Airborne within.2s.
- HipDrop1.05 and camera drop.65; camera still follows stance. Floor-aware visual clearance checks foot/shin/torso bounds and respects the survivor collision group. No root teleport drive or fake displacement.
- Both arms use two-bone joint solutions. Five weapon-specific grip/support targets; pistols cup the grip and long guns support the fore-end. Barrel follows aim pitch, independent of body lean.
- One post-Animator writer combines slide/crouch/aim. ClaudeThirdPerson keeps its camera/mouse/AimPitch block, while its competing arm writer is removed. MovementClient starts the new module. No rig attachment rewrites.
- Current camera is THIRD PERSON ONLY, existing shoulder offset/zoom8 unchanged. Earlier V-toggle documentation is historical.

## How we'd build it in Roblox
- ReplicatedStorage.GameplayPresentation.CharacterPose: client ModuleScript, per-player replicated MovementState/MovementCrouched/AimPitch; joint Transform writes at PreSimulation and restoration at PreAnimation. Periodic rig-joint discovery handles late-arriving joints.
- ReplicatedStorage.GameplayPresentation.MovementClient and MovementConfig: bootstrap and stance tuning; existing MovementControl.State includes actual pose diagnostics.
- ServerScriptService.GameplayMovement.Service: only ground() transition ray range changed. Existing validated MovementRequest, stamina, LinearVelocity drive and cancellation remain server authoritative.
- StarterPlayerScripts.ClaudeThirdPerson: bounded pose-only replacement, authorized directly by user. Combat sources ClaudeAKServer.Logic, ReferenceWeapons.Controller/WeaponConfig plus LobbySystem.Client compare unchanged.
- ServerStorage.README_CONTRACT was absent during inspection; no contract invented. Source backup: ServerStorage.SlideAndGripBackup_20261017.

## Tested
- Fresh Play; normal client-owned movement through real controls in lobby and arena. Slide speed~34->18, about22studs by.8s, then standing hip and pose restore.
- Separate road recording:27 samples, minimum mid-slide sampled body clearance~.079stud. Not an all-map clearance guarantee.
- All5 weapons at-35/0/+35degrees:15 cases. Support target error max.0177stud; pitch error<.001degree. Actual player side view inspected, not clone-only.
- Four crouch cycles, support hold, speed8 and camera lowering; fire ammo30->29, reload->30; lobby return unarms and leaves no slide drive.
- Complete installer plus rollback ran on isolated Studio source fixture. Four original sources restored, new module removed, live5-source update retained. Executable shell rollback self-test passed on disposable JSON copy.
- Existing cloud/CoreUI/asset203785492 warnings remain unrelated. Real two-client observation, unusual avatar scales, Motor6D avatar and exhaustive terrain/low-ceiling acceptance remain.

## Evidence and rollback
[[04 Scripts/Slide Animation And Two-Handed Hold/VERIFICATION.txt]] records exact commands, inputs, literal outputs, hashes and statuses. Installer, unified diff, baseline, final sources, tests, source fingerprints and executable ROLLBACK.sh are in that folder.
Original baseline JSON SHA256:3AC53757CFE9236D1A4544077FDE6E28151689084975F8E4926B8B7F560EF52D.
RESTORE.luau restores the four preserved sources and removes CharacterPose. The live game remains modified.

## Reusable follow-up prompt
```text
Inspect the latest session log, Third Person Combat and Slide Animation And Two-Handed Hold first. Preserve the third-only camera and all firing/damage code. Test actual client-owned slides, real avatar joint types, floor clearance through entry/recovery and both hand targets before changing pose profiles. Check ownership and concurrent source changes; keep isolated rollback evidence and commit Studio drafts.
```

## Newer crouch/camera/input repair
[[Private Sessions And Zombie Opening]] removes the physical crouch hip drop, deepens the supported-joint crouch pose and uses normal/aimed camera zoom6.2/4.2. Added tap-only circular aim presentation; original slide drive/ground-range fix retained.
