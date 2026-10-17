---
type: reference
area: systems
owner: shared
status: idea
sources:
  - raw/2026-10-16-hood-warfare-2-reference-pack.md
updated: 2026-10-16
tags: [reference, systems, game-modes]
---

# Hood Warfare 2 Game Modes

## Mode branches

- **Turf War:** contested regions award score over time.
- **Team deathmatch:** two teams compete on eliminations.
- **Free-for-all:** every player competes independently.
- **Capture-the-object:** take an opposing object home while defending yours.
- **Attack and defend:** attackers plant; defenders defuse; rounds can use one life.
- **Kill-confirmed collection:** collect enemy drops and recover friendly drops.

## How we'd build it in Roblox

- **Instances:** objective `Part`s tagged with `CollectionService`, score `IntValue`s, and `Folder`s in `Workspace.Objectives`.
- **Services / APIs:** `ServerScriptService.GameModes`, `ReplicatedStorage.Remotes`, and `RunService` timers.
- **Where it lives:** each mode is a server `ModuleScript` with a shared round-state contract.
- **Client vs server:** server owns score, captures, drops, timers, and round state; client renders HUD feedback.

## Related

- [[Hood Warfare 2 Reference Pack]]
- [[Hood Warfare 2 Roblox Build Plan]]
