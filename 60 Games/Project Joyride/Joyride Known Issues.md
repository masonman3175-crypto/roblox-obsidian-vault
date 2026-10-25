# Joyride Known Issues

Back to [[Project Joyride - Game Hub]].

- **Multiplayer not tested.** Code supports a truck per player (spawn slots, per-player ownership and score) but MCP playtests are solo. Test with Studio's 2-player local server.
- **No client hit prediction.** Dummies fly when the server confirms. Instant in Studio, but with ~100ms ping the truck passes a dummy before it launches.
- **No engine or skid sound.** Built-in Roblox sounds have none. Put asset ids in `Config.Effects.Sounds.Engine` / `.Skid`. Impact, pop, milestone and wind use built-in sounds.
- **Source only lives in Studio.** The spec asked for a Rojo tree. Rojo isn't installed, so scripts were written straight into Studio. Save the place, or export the scripts to files.
- **Place is unsaved** (Place2). Save it in Studio.
- **Roll looks small in normal turns** (about 4.6 deg at half lock). Raise `Roll.MaxDegrees` or lower `ReferenceLateralAccel` if Cade wants more lean.
- **Truck is built from parts.** A Blender body could replace it later.
- Debug text box is taller than its text (cosmetic).
