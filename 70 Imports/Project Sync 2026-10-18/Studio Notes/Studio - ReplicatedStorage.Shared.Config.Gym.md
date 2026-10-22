---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Config.Gym

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Config.Gym`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Gym.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Config/Gym.luau)

```luau
-- Gym pads in the hub (Workspace.Map.Gameplay.GymPads.GymPad<Tier>).
-- Standing on an unlocked pad multiplies Strength gain. Unlock by rebirths or a pass.
local Gym = {}

Gym.Tiers = {
	{Name = "Bench", Multiplier = 2, Rebirths = 0},
	{Name = "Squat Rack", Multiplier = 3, Rebirths = 1},
	{Name = "Golden Dumbbells", Multiplier = 5, Rebirths = 3},
	{Name = "VIP Bench", Multiplier = 10, Pass = "GymVIP"},
	{Name = "Mega Machine", Multiplier = 25, Pass = "GymMega"},
	{Name = "Admin Throne", Multiplier = 99, Pass = "GymAdmin"},
}

return Gym

```

