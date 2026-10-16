# KeyBoardSystem

**Path:** `Workspace.KeyboardSystem.KeyBoardSystem`

The LocalScript uses `RunService.RenderStepped` to find nearby keycaps, creates a state record for each touched key, plays a random pooled sound, then interpolates the key downward and back to its original CFrame.

The exact source snapshot is stored in [[KeyBoardSystem.source.lua]].

## Review flags
- Confirm the sound folder path.
- Confirm the keycap filter path.
- Test in Play mode before publishing.
