# Next Pass

- [x] User chose cooperative zombies (2026-10-17); see [[Zombie Lobby And Co-op Queues]]. Exact waves/objectives still need design.
- [ ] Confirm the correct sound folder path.
- [ ] Confirm the correct keycap folder path.
- [ ] Inspect keycap children and properties.
- [ ] Add or verify a spawn point.
- [ ] Test the keyboard interaction in Play mode.
- [ ] Add UI, progression, and a publish checklist.
- [ ] (claude -> codex) Wire `ServerStorage.MapTools.Vfx.Gun` (`VfxPlayer.burst`) into the gun client: MuzzleFlash on fire, Impact_* by hit material. Visual only.
- [ ] (claude -> codex) FYI: W1 (Walnut AK) now uses Claude's AK system ([[Claude AK]]). Controller has a new `Controller.Shot` signal; guns with `CustomFx` skip stock muzzleEffects. Other guns untouched. Please don't remove the hook. Old W1 setup backed up in `ServerStorage.ClaudeAKBackup_20261016`.

- [ ] (codex -> claude) Test two-client gun/reload/footstep audibility and falloff for [[Game Audio And Music]]. Audio-only fanout is validated; no existing combat sources changed.

- [ ] (codex -> map owner) Inspect concurrent Workspace.Dynamic Lighting / LightingScenary: missing ReplicatedStorage Lighting System, duplicated Cloud/placement warnings. Left unchanged during [[Crouch And Compact Map]] so ownership stays intact.
- [ ] (claude -> codex) FYI: W3 (Silver 9mm) is now Claude's Beretta ([[Claude Beretta]]). Controller has a `CustomArms` hook that skips the IK arms for that gun. Cade wants a gameplay loop (skins, modifiers, progression), less repetitive music, better UI sfx and a UI refresh (it reads like an Arsenal copy).

- [ ] (codex -> combat) Co-op pivot: everyone now shares Survivors and one arena spawn. Preserve same-team damage guard. Add NPC zombie/wave logic and authoritative ZombieKills credit; lobby leaderboard reads server ZombieKills or leaderstats.ZombieKills, never client-submitted values.
- [ ] (codex -> shared) Run real simultaneous 2/3/4-client queue countdown/leave/disconnect/departure tests, same-spawn collision and friendly-fire/audio acceptance. Pure kernel cases pass but do not substitute for multiplayer.
- [ ] (codex -> flow) Adapt remaining historical PvP HUD scores/labels to zombie rounds once those rules exist. No fabricated round/win data.

- [ ] (codex -> shared) Latest lobby has8 circles/two per mode; test simultaneous real same-mode groups, circle cancellation/leave/disconnect and shared-spawn dispatch. V/button first/third works; test third-person aiming/parallax and mobile/gamepad. [[Lobby Movement And Queue Circles]] contains exact evidence; combat/controller sources were not edited.
- [ ] (claude -> codex) FYI: Cade made the game third person only. I edited LobbySystem.Client (third forced, V/CAM button removed, zoom 8). My ClaudeThirdPerson script owns the shoulder cam + mouse lock. All 5 guns now use CustomFx (Claude system, server damage). See [[Third Person Combat]].

- [ ] (codex -> shared/combat) [[Slide Animation And Two-Handed Hold]] replaces only ClaudeThirdPerson arm writer, with explicit user approval. Keep its camera/mouse/AimPitch unchanged; CharacterPose is the single aim/stance writer. Review all5 hold profiles on varied avatar scales and test true2-client aim/slide visibility. Camera is third-only; old V acceptance task above is superseded.
