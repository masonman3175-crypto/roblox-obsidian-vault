# Ground and team spawn changes

- Workspace.Baseplate: Material Plastic -> Asphalt; Color #5b5b5b -> MainRoad #58585a; MaterialVariant cleared; checker Texture.Transparency 0.8 -> 1. Size, transform and collision unchanged.
- Workspace.Map.Spawns.Spawn_West: neutral -> Crips (Bright blue), NW (-235,0.5,-135), facing center.
- Workspace.Map.Spawns.Spawn_East: neutral -> Bloods (Bright red), SE (245,0.5,135), facing center.
- Teams: two native AutoAssignable Team objects; no new gameplay scripts, remotes, weapons, menu logic or building changes.
- In-Studio exact-object backup: ServerStorage.GroundTeamSpawnsBackup_20261017. RESTORE.luau restores only changed fields; cloned fixture test leaves live update in place.

