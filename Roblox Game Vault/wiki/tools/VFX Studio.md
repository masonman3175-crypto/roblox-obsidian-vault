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

## Install + how we use it (2026-10-16)
- **Not installed yet** on Cade's PC (checked `%LOCALAPPDATA%\Roblox±9220008\InstalledPlugins`).
- **Install (Cade):** open the store link, click **Get**, then in Studio: Toolbox > Inventory > My Plugins (or Plugins tab > Manage Plugins) > install, then restart Studio.
- **What Claude can and cannot do:** the Studio MCP cannot click plugin UI. Claude can read and edit whatever the plugin puts in the place (ParticleEmitters, Attachments, Beams, any preset folders), copy those into `ServerStorage.MapTools.Vfx`, and wire them up. So: Cade builds or picks an effect in VFX Studio and drops it in the place, then Claude takes it from there.
- First job for it: replace the default `fire_main.dds` and `smoke_main.dds` textures in [[Map VFX Library]] (BarrelFire) with VFX Studio fire and smoke.

## Installed + vetted (2026-10-16)
- Installed by Cade (`InstalledPlugins/135581141962270`). Claude read all 417 scripts via `game:GetObjects`: no `loadstring`, no remote `require`, no backdoor. Web calls are only GETs to the author's GitHub (Sytranom/VFXStudio): `latestversion.txt` and `VFXData.json` (a texture list). Safe.
- Ships `Defaults.Meshes` (547 effect meshes: shockwaves, swirls, impacts, rings) and `VFXData.json` (9,178 textures tagged Fire, Smoke, Spec, Impact, Flare, Lightning, Swirl, Energy, Slashes, Ground, Water, Star...).
- **How Claude uses it:** cannot click the plugin UI, but uses its texture library and meshes directly. A local copy of `VFXData.json` makes it searchable by name/keyword.
- Good picks: flame `1058335870`, fire `883906867`, smoke `122434532`, spark `528280947`/`271370648`, dust `13388193136`, steam `114122485080069`, muzzle `12363834197` (+ `muzzle_flash_*` set), soft flash `9841273835`, wood debris `425665059`. New textures take a few seconds to stream in before they show.
