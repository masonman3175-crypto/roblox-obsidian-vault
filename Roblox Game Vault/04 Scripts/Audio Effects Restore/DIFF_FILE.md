# Effects-Only Audio Repair
- Root cause: BackgroundMusic was deleted; Client.Start waited for it and asserted before installing any effect hooks.
- Client.Start now depends only on GameAudioEffects and 12 effects. Removed track playback/fallback/preload, music GUI, F8 and music setters.
- Config removes both track IDs and music settings; existing native W1/W3 shot support follows current combat configuration. Native shot sound names ClaudeShotW1_*/ClaudeShotW3_* are counted once, preserving the collaborator's pistol sound.
- Native ClaudeReload is locally muted/restored while this presentation pack owns reload audio, preventing two overlapping clips.
- SoundService.BackgroundMusic and GameAudioMusic absent; two music templates removed from active Assets (backup originals retained).
- Only AudioPresentation.Client/Config, its own asset/mix properties changed. Audio Server/bootstrap sources remain unchanged.
- 16 external source fingerprints inspected: 14 stable; ClaudeAKClient and ReferenceWeapons.WeaponConfig changed concurrently by the collaborator. Neither is assigned by this installer or restore script.
- Backup: ServerStorage.AudioSfxRestoreBackup_20261017.
