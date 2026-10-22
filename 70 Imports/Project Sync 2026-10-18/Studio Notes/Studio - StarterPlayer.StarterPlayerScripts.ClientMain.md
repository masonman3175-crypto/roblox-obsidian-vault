---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - StarterPlayer.StarterPlayerScripts.ClientMain

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `StarterPlayer.StarterPlayerScripts.ClientMain`

**Class:** `LocalScript`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [ClientMain.luau](../Files/Studio%20Snapshot/Project%20Source/StarterPlayer/StarterPlayerScripts/ClientMain.luau)

```luau
local Controllers = script.Parent:WaitForChild("Controllers")

-- PlayerScripts descendants can arrive over several replication frames.
-- Wait independently for every shipped controller instead of silently skipping UI.
for _, name in {"HudController", "PunchFxController", "PetController",
	"PetsController", "HatchController", "ShopController", "EggMenuController"} do
	task.spawn(function()
		local ok, err = xpcall(function()
			local module = Controllers:WaitForChild(name)
			local controller = require(module)
			if controller.Start then controller.Start() end
			script:SetAttribute(name .. "_Ready", true)
		end, debug.traceback)
		if not ok then
			script:SetAttribute(name .. "_Error", tostring(err))
			warn("[ClientMain] " .. name .. " startup failed: " .. tostring(err))
		end
	end)
end

```

