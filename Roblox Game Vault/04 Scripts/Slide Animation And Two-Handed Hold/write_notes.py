import pathlib,shutil,hashlib,json
r=pathlib.Path(__file__).parent
v=pathlib.Path(r"C:\Users\mason\OneDrive\Documents\Obsidian Vault\Roblox Game Vault")
dest=v/'04 Scripts/Slide Animation And Two-Handed Hold';dest.mkdir(parents=True,exist_ok=True)
# Preserve only this task's artifacts; no original video or unrelated drafts.
for p in r.iterdir():
 if p.is_file() and (p.suffix in {'.luau','.json','.txt','.md','.sh','.py'} or p.name=='REFERENCE_SHEET.jpg'):
  shutil.copy2(p,dest/p.name)
(dest/'.gitattributes').write_text('*.sh text eol=lf\n',encoding='utf-8')
def append(path,text):
 p=v/path;p.parent.mkdir(parents=True,exist_ok=True)
 with p.open('a',encoding='utf-8') as f:f.write(text)
def replace(path,old,new):
 p=v/path;t=p.read_text(encoding='utf-8');assert old in t,(path,old);p.write_text(t.replace(old,new),encoding='utf-8')
(v/'raw/2026-10-17-slide-and-aim-reference.md').write_text("""# User Movement And Aim Clip
- Original read-only video: C:/Users/mason/Downloads/v12044gd0000dari477og65rmfl0qa80.mp4
- SHA256: 41F91F961F3F08A19D2AE1DC3FDB3C8EAB09EC81C34CAC4048E42B3FF4548254
- Duration35.90s, 576x1024, 30fps. Twelve extracted frames and contact sheet were actually opened, including21s close aiming view.
- Observed reference: shoulder-view aiming, close framing during aiming, support arm crossing in front to steady the weapon, barrel following vertical aim. The clip is an aim reference, not a verified slide animation source.
- Source video is not copied into Git or uploaded to Roblox. Contact sheet: [[04 Scripts/Slide Animation And Two-Handed Hold/REFERENCE_SHEET.jpg]].
- Implementation: [[Slide Animation And Two-Handed Hold]]. Original animation assets and exact motion curves are not supplied.
""",encoding='utf-8')
(v/'wiki/systems/Slide Animation And Two-Handed Hold.md').write_text("""---
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
""",encoding='utf-8')
replace('wiki/index.md','## Systems\n','## Systems\n- [[Slide Animation And Two-Handed Hold]] - rig-compatible slide animation, stable ground transition and five two-handed weapon holds (shipped)\n')
replace('wiki/index.md','lobby sprint/slide, V camera toggle, eight independent circular queues and no title banner','lobby sprint/slide, eight independent circular queues and no title banner; camera now third-only')
append('wiki/systems/Lobby Movement And Queue Circles.md','\n## Later third-person and animation update — 2026-10-17\n[[Third Person Combat]] supersedes the V-toggle/camera-button instructions above: the game is now third-person only. [[Slide Animation And Two-Handed Hold]] adds actual rig-compatible slide/crouch poses and repairs premature client-owned slide cancellation. Eight queue circles remain unchanged.\n')
append('wiki/log.md','\n## [2026-10-17] update | Slide animation and two-handed hold (codex)\n- New [[Slide Animation And Two-Handed Hold]], immutable clip descriptor and source/test/rollback archive; updated index, lobby-camera supersession note, hub, tasks, devlog and session log.\n- Real AnimationConstraint rig, normal client-owned arena/lobby travel,15 weapon/pitch cases, crouch cycles, fire/reload and return pass; bounded pose integration explicitly approved by user.\n- Isolated installer/rollback and executable copy rollback pass; five live modified sources retained, four unrelated combat/camera sources unchanged.\n')
append('wiki/devlog/2026-10-17.md','\n- [[Slide Animation And Two-Handed Hold]]: actual bent-leg sliding animation instead of sinking, corrected premature ground-loss cancellation, camera stance movement and two-handed holds on all5 guns. Current third-only camera and damage code preserved.\n')
append('08 AI Workflow/Session Logs/2026-10-17-codex.md','\n## Slide animation and two-handed hold\n- Read latest collaborator third-person work; inspected35.90s user clip and actual live R15 AnimationConstraint joints. README_CONTRACT absent. User explicitly approved pose/grip-only edits in Claude camera script; no firing/damage change.\n- CharacterPose unifies stance/aim writers, supports both joint APIs, two-bone hand targets for W1-W5, floor-aware root pose correction and entry/recovery. HipDrop1.05/CameraDrop.65. Fixed server ground ray shrinking early and cancelling normal client-owned slides.\n- Tests: lobby/arena client-owned glide~22studs,27 road clearance samples,15 gun/pitch cases(max support error.0177stud),4 crouch cycles,30->29 fire/reload30, Return unarmed/no drive. Live side gun view inspected. Script stack checks clean; old cloud/CoreUI/asset warnings unchanged. Real multiplayer/unusual rigs/terrain still need acceptance.\n- Exact5 final source checks and4 unchanged combat/camera checks; original4 sources in ServerStorage.SlideAndGripBackup_20261017. Full installer and rollback on isolated Studio fixture pass; executable shell copy rollback exit0. Live remains modified in Edit.\n- Archive [[04 Scripts/Slide Animation And Two-Handed Hold/VERIFICATION.txt]], wiki [[Slide Animation And Two-Handed Hold]]. Commit Studio drafts / let Team Create save before partner tests.\n')
append('06 Tasks/Next Pass.md','\n- [ ] (codex -> shared/combat) [[Slide Animation And Two-Handed Hold]] replaces only ClaudeThirdPerson arm writer, with explicit user approval. Keep its camera/mouse/AimPitch unchanged; CharacterPose is the single aim/stance writer. Review all5 hold profiles on varied avatar scales and test true2-client aim/slide visibility. Camera is third-only; old V acceptance task above is superseded.\n')
append('00 Dashboard/Game Development Hub.md','\n## Latest movement/hold repair — 2026-10-17\n- [[Slide Animation And Two-Handed Hold]]: procedural slide pose + real ground-transition fix, floor clearance and two-hand weapon support.\n- [[Third Person Combat]] remains the camera direction: third only, no V toggle.\n- [[04 Scripts/Slide Animation And Two-Handed Hold/VERIFICATION.txt]] contains exact tests and rollback. Commit Studio drafts before partner acceptance.\n')
count=0
for src in r.iterdir():
 target=dest/src.name
 if src.is_file() and target.exists():
  assert hashlib.sha256(src.read_bytes()).digest()==hashlib.sha256(target.read_bytes()).digest(),src.name
  count+=1
print('PASS:',count,'archived artifacts reopened and SHA256 matched')
print('ARCHIVE',dest)
