---
type: system
owner: flow
status: building
sources:
  - raw/2026-10-16-main-menu-reference.png
updated: 2026-10-16
---

# Main Menu Source

Source mirror for the currently installed [[Main Menu And Locker]] in hood warfare 1.2.
These are notes/source backups, not a standalone place file or a new asset importer.

| File | Studio destination |
|---|---|
| MODIFIED_FILE.luau | ReplicatedStorage.MainMenu.Client |
| MenuConfig.luau | ReplicatedStorage.MainMenu.MenuConfig |
| Cosmetics.luau | ReplicatedStorage.MainMenu.Cosmetics |
| Server.luau | ServerScriptService.MainMenuSystem.Service |
| WeaponController.luau | ReplicatedStorage.ReferenceWeapons.Controller |

Thin server Boot: `require(script.Parent.Service).Start()`.
Thin client MainMenuClient: `require(game:GetService('ReplicatedStorage'):WaitForChild('MainMenu'):WaitForChild('Client')).Start()`.

Existing dependencies: ReferenceWeapons.WeaponConfig, Viewmodels.W1-W5, existing StarterPack Tools, and MainMenu.Assets.PreviewRig (the original generated R6 preview, scripts stripped). MainMenu.Request is a RemoteFunction. No uploaded image assets are required for this UI.

## Verify / restore

- `python verify.py BASELINE` confirms the preserved minimal-menu condition.
- `python verify.py MODIFIED` checks expected source features; runtime QA is recorded in VERIFICATION.txt.
- `./ROLLBACK.sh rollback-copy.luau` restores only a separate local source-copy fixture. Live modified source stays intact.
- `restore_main_menu.luau` is the actual Edit-mode game rollback. It restores the original weapon Controller from ServerStorage.MainMenuBackup_20261016, removes menu packages/boots/focus and returns CharacterAutoLoads to its saved value. It never changes the map/spawns.
- `restore_fixture_test.luau` runs that exact restoration against isolated cloned services without undoing the installed game.
- DIFF_FILE.patch compares the preserved minimal menu to the revised aerial menu.

Source-file hashes are kept byte-for-byte via this folder's .gitattributes. Session-only cosmetics and rank placeholder are intentional.

Related: [[Main Menu And Locker]], [[08 AI Workflow/Session Logs/2026-10-16-codex|Codex session log]].
