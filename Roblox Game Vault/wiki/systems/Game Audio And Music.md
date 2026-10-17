---
type: system
owner: flow
status: shipped
sources:
  - https://create.roblox.com/store/asset/107491422176664
  - https://create.roblox.com/store/asset/9042281328
  - https://create.roblox.com/docs/reference/engine/classes/Sound
updated: 2026-10-17
---

# Game Audio And Music

Independent audio presentation for [[Main Menu And Locker]], [[Sprint Slide And Map Boundary]] and [[Claude AK]]. Installed in hood warfare 1.2 (127865723083651).

## What plays
- Distinct rifle, pistol and shotgun reports for all five imported weapons; reloads, shotgun shell insertion/pump, equip, ADS, inspection, dry click and casings.
- Spatial concrete/grass footfalls for walking/sprinting, quieter crouched movement, cloth slide/jump, landing/death. No idle or airborne footfalls.
- Menu/UI clicks and server-confirmed hit, headshot and elimination cues.
- Creator Store drill instrumental at **5%**. F8 or Music button mutes/unmutes without restarting the track; settings are session-local.
- Music: catalog ID 107491422176664 (DistrokidOfficial); APM trap fallback 9042281328. This is not a King Von recording.

## Instances and integration
- ReplicatedStorage.AudioPresentation: Config, Client, Server, Assets (14 Sounds, zero scripts in imported assets), Emit RemoteEvent.
- StarterPlayerScripts.AudioPresentation / ServerScriptService.AudioPresentation: thin bootstrap scripts.
- SoundService.BackgroundMusic: Volume 0.05, Looped true; GameAudioMusic / GameAudioEffects SoundGroups each Volume 1.
- Observes existing FPSWeaponId/FPSAmmo/FPSReloading/FPSAiming/FPSInspecting and movement attributes. Existing W1 sounds remap locally, not duplicate.
- Audio-only peer fanout validates action, payload arity, liveness/deployed state, equipped weapon whitelist and cadence. Clients supply no SoundId/position/volume. Damage/ammo/rewards remain in existing systems.
- Nearby player footfalls derive from observed displacement, raycast material and grounded state on each client. Native movement sounds are locally muted and restored on teardown.

## Verified
- All 14 assets decoded in Client Play; primary music 112.2 seconds, Volume 0.25, playing with nonzero measured loudness.
- Real PLAY button; W1-W5 each fired exactly one shot cue and reloaded. Reload cancellation on switch passed.
- Actual walk/sprint, slide, jump and landing cues; idle silent. Real F8 mute/unmute passed.
- Existing confirmation remote exercised hit/headshot/elimination cues; no damage/rewards changed.
- Audio remote whitelist/cadence tests passed; three malformed actual requests increased server rejection count by three.
- Teardown restored native Running volume to 0.65 and cleared voices/connections. Restart connection count stayed 63 -> 63.
- Nine original inspected Source strings unchanged. No map/spawn/weapon/menu/movement code overwrites.
- Actual isolated rollback restored audio-free clones; live update retained.

## Evidence and remaining checks
- [[04 Scripts/Game Audio And Music/Implementation|Source, assets and full verification]].
- ServerStorage.AudioPresentationBackup_20261017 marks baseline; BASELINE.json preserves original inspected sources.
- Simultaneous two-client sound listening/falloff is not tested. Audio fanout is not new server weapon damage authority.
- Existing UIBlox messages and asset 203785492 type mismatch remain unrelated.
- Let Team Create save and commit Studio drafts. No public publish performed.

## Later 2026-10-17: quieter default
- User found 25% too loud. [[Crouch And Compact Map]] changes the current default to 5% in Config and BackgroundMusic; F8/click mute and 14 assets retained.
- Earlier 25% test measurements above describe the initial audio pass, not the current default.