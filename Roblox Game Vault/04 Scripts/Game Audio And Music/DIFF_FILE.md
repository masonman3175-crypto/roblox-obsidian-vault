# Audio presentation pass

- Added ReplicatedStorage.AudioPresentation: Assets (14 searched/imported audio Sounds, 0 scripts inside assets), Config, Client, Server, Emit.
- Added thin StarterPlayerScripts.AudioPresentation and ServerScriptService.AudioPresentation boots.
- Added SoundService.BackgroundMusic: Looped=true, Volume=0.25, Creator Store drill instrumental (catalog track, not a King Von recording).
- Added GameAudioMusic / GameAudioEffects SoundGroups at Volume=1, so music effective scalar is exactly 0.25 before user/device master volume.
- Per-weapon gunshot, reload, equip, ADS, inspect, shell, pump, dry fire; walk/sprint footsteps and softer crouched footfalls; cloth slide/jump, landing/death, UI and server-confirmed hit/headshot/elimination cues.
- Native duplicate movement sounds are suppressed only locally and restored on teardown. Existing W1 sounds are remapped locally; W1 broadcast is not duplicated.
- Other weapon Shot/Reload/Equip audio fanout accepts only fixed actions and the server-observed equipped weapon; validates liveness/menu, arity and cadence. It has no gameplay authority.
- Default music is 25%; F8 or the Music button mutes/unmutes. Settings are session-local.
- Source equality check: all 9 pre-existing inspected modules/scripts unchanged, including combat/controller/config, weapon FX, menu boot, movement/HUD boot. Ground/spawns untouched.
- Backup marker ServerStorage.AudioPresentationBackup_20261017; full original inspected sources in BASELINE.json. RESTORE.luau tested on isolated modified clones. Live update retained.

