# Game Overview

## Identity
- **Place:** o blah warfare 1.1
- **Place ID:** 80506494260443
- **Current concept:** An interactive keyboard scene in Roblox.

## Player loop
1. Player moves across the keyboard.
2. Nearby keycaps are detected.
3. Keycaps press downward.
4. A keyboard sound plays.
5. Keycaps smoothly return.

## Known gaps
- The script expects `ReplicatedStorage.Sounds`, but the captured sounds are under `Workspace.KeyboardSystem.Sounds`.
- The script checks `workspace.Keycaps`, while the captured folder is `Workspace.KeyboardSystem.Keycaps`.

See [[02 Systems/Keyboard System]] and [[06 Tasks/Next Pass]].
