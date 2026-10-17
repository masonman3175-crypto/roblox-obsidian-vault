---
type: tool
area: tools
owner: shared
status: planned
sources:
  - https://create.roblox.com/store/asset/135581141962270/VFX-Studio
updated: 2026-10-16
tags: [tool, plugin, vfx]
---

# VFX Studio

Roblox Studio plugin for making VFX.

## Verified facts
From the Creator Store listing (2026-10-16):
- **Asset ID:** `135581141962270` (plugin)
- **Creator:** XxOmqxXNerd
- **Price:** free (no Robux price listed)
- **Listing says:** "AIO (soon to be) vfx tool", so it's still growing
- **Released:** 2025-05-31, **last updated:** 2026-09-07

## Features
_Not verified yet. Fill in after trying it in Studio. Don't guess._
- 

## How we use it
- Build and tune effects for [[index#VFX|VFX pages]] (muzzle flash, tracers, hit effects).
- Export the result as normal Instances (ParticleEmitter, Beam, Trail, Attachment) and store them where the contract says.

## Rules
- Plugin output is just Instances. Check for any Scripts it adds and delete them before committing, same as store assets.
- Effects are client-side visuals. Never let a VFX script decide hits or damage.
- Keep particle counts mobile friendly.

## Install
1. Open the store link above, click Get.
2. In Studio: Plugins tab > VFX Studio.

## Open questions
- What does it actually do (editor, presets, emitter tools, timeline)?
- Does it insert any scripts or modules at runtime?
- Does it work in Team Create for both of us?

## Related
- [[index]]
- [[Reference Note]] template, section "How we'd build it in Roblox"
