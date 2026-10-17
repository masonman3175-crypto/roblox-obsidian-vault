# Crouch, Compact Boundary, Floor Repair and Quiet Music

- AudioPresentation.Config.MusicVolume and SoundService.BackgroundMusic.Volume: .25 -> .05 (5x quieter amplitude, about -14 dB). Existing music toggle continues to restore the new default.
- MovementConfig: crouch speed 8, hip drop .60 and camera offset .95. Combined actual camera drop measured 1.55 studs.
- MovementClient: C/Ctrl/B toggles crouch when not sprinting; sprint+C/B still slides, including chains. Smooth pre-camera transition and additive R15 knee/hip/ankle/waist posture, without Motor6D.C0 mutation. Crouch/stand reset on menu and redeploy.
- GameplayMovement.Service: server-validated Crouch boolean and arity, grounded entry, reduced speed/height and blocked standing under low ceilings. Existing sprint/slide authority retained.
- MainMenu.Client: controls help includes crouch/sprint/slide.
- Perimeter inner limits X[-262,272], Z[-150,150] -> X[-236,246], Z[-122,122], flush to outer building extents. Area 160200 -> 117608 square studs, 26.5868% smaller. Four wall solids/details and minimap boundary proxies resized/repositioned; buildings unchanged.
- Spawns moved inside: blue (-186,.9,-115), red (182,.7,108), still opposite corners and team-only. Both actual deployments passed; 242 pad rays clear.
- Removed four coplanar border aprons, lowered base floor top by .16, separated sidewalk support from tile tops, clipped tiles around soil/curb footprints (455 -> 500 pieces), hid one redundant overlapping road patch. Detected broad opaque floor coplanar pairs 12 -> 0. No ground holes introduced.
- Source/geometry backup: ServerStorage.CrouchCompactFloorBackup_20261017. Actual rollback function tested on isolated full geometry/source copies; live modifications retained.
- Unrelated concurrent Dynamic Lighting/LightingScenary missing Lighting System error left untouched and logged for map owner.

