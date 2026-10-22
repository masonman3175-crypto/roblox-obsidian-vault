---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.Main

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.Main`

**Class:** `Script`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [Main.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/Main.luau)

```luau
-- Starts every service. DataService goes last so the others are listening
-- before the first profile loads.
local Services = script.Parent.Services

local ORDER = {
	"StatService",
	"TrainingService",
	"ZoneService",
	"RebirthService",
	"PunchService",
	"EggService",
	"MonetizationService",
	"LeaderboardService",
	"DataService",
}

for _, name in ORDER do
	local service = require(Services[name])
	service.Start()
end

```

