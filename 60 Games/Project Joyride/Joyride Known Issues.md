# Joyride Known Issues

Back to [[Project Joyride - Game Hub]].

- **Multiplayer not tested.** Code supports a truck per player but MCP playtests are solo. Test with Studio's 2-player local server.
- **EditableMesh in a published game (unverified).** The Blender truck is built at runtime with EditableMesh. It works in Studio. Published games may need the account to meet Roblox's Editable API rules. If it fails, the parts truck shows instead (fallback is built in). The safer long-term path is importing `joyride_truck.fbx` with the 3D Importer.
- **Blender body is 17k triangles.** The boolean arch cuts on bevelled shells add a lot. Fine at 60 fps here; could be trimmed.
- **Source only lives in Studio.** No Rojo export. Save the place.
- **Place is unsaved** (Place2). Save it in Studio.
- **Audio is off** on purpose (V2). Set `Config.Audio.Enabled = true` and add ids to bring it back.
- **Drift roll overshoots** about 3 deg past the 16 deg cap.
- Feel tuning was done from numbers and screenshots, not by a human driving.
