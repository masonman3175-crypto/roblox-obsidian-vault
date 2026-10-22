---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ReplicatedStorage.Shared.Config.Rebirth

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ReplicatedStorage.Shared.Config.Rebirth`

**Class:** `ModuleScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Rebirth.luau](../Files/Studio%20Snapshot/Project%20Source/ReplicatedStorage/Shared/Config/Rebirth.luau)

```luau
local Rebirth = {}

function Rebirth.LevelRequired(rebirths)
	return 10 * (rebirths + 1)
end

function Rebirth.Multiplier(rebirths)
	return 1 + 0.5 * rebirths
end

return Rebirth

```

