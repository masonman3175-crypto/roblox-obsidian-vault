---
type: source
status: snapshot
updated: 2026-10-18
tags: [roblox, project-sync]
---

# Studio - ServerScriptService.TrackExtensionRuntime

Back: [[70 Imports/Project Sync 2026-10-18/Project Sync - Start Here|Project Sync]]

**Instance:** `ServerScriptService.TrackExtensionRuntime`

**Class:** `Script`

**Provenance:** current Studio Play server snapshot; not proof of cloud publication.

Raw source: [TrackExtensionRuntime.luau](../Files/Studio%20Snapshot/Project%20Source/ServerScriptService/TrackExtensionRuntime.luau)

```luau
-- Only authoring previews are removed in Play. The original six biomes stay intact.
local track=workspace:WaitForChild("Map"):WaitForChild("Track")
local preview=track:FindFirstChild("ExtensionsPreview")
if preview then
 for _,world in ipairs(preview:GetChildren()) do world:Destroy();task.wait() end
 preview:Destroy()
end
print("[TrackExtension] original biomes=6; appended landscape catalog=60; extra runtime world budget=8")


```

