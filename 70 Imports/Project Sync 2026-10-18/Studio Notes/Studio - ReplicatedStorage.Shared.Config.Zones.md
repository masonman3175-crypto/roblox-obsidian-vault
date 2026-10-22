---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Config.Zones

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Config.Zones`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Zones.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Config/Zones.luau)

```luau
-- Worlds (kept the module name Zones). World 1 is the hub; 2-5 are islands
-- reached through portals. You count as "in" a world within Radius of its Center.
-- Required = Strength to use the portal. Multiplier applies while you are there.
local Zones = {}

Zones.Radius = 260

Zones.List = {
	{Name = "Hub", Required = 0, Multiplier = 1, Color = Color3.fromRGB(110, 220, 90), Center = Vector3.new(0, 0, 0)},
	{Name = "Candy", Required = 1000, Multiplier = 3, Color = Color3.fromRGB(255, 120, 200), Center = Vector3.new(0, 0, -1600)},
	{Name = "Frost", Required = 100000, Multiplier = 10, Color = Color3.fromRGB(90, 190, 255), Center = Vector3.new(0, 0, -2800)},
	{Name = "Lava", Required = 10000000, Multiplier = 40, Color = Color3.fromRGB(255, 110, 40), Center = Vector3.new(0, 0, -4000)},
	{Name = "Space", Required = 1000000000, Multiplier = 150, Color = Color3.fromRGB(150, 90, 255), Center = Vector3.new(0, 0, -5200)},
}

return Zones

```

