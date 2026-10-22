---
type: tool
game: hub
owner: shared
status: building
sources:
  - Map passes 1-4, lighting passes (2026-10-16)
updated: 2026-10-16
tags: [tool, studio, mcp, gotchas]
---

# Studio MCP Gotchas

Things that bit Claude while building the FPS map (other vault) through the Roblox Studio MCP. Read before doing big builds. Setup is in [[70 Imports/Ultimate Slop Hub/wiki/tools/Studio MCP Reference|Studio MCP Reference]].

## Building
- **Generated meshes (`generate_mesh`) come in with the pivot in the middle.** Placed at ground height they sink halfway. Move the pivot to bottom-center first (set `PrimaryPart.PivotOffset`).
- **Store models can have the pivot somewhere random.** The oak pack had the pivot on a leaf clump, up to 21 studs from the trunk. Find the real base before placing.
- **`GetBoundingBox` follows the PrimaryPart's rotation**, not the world. For "is this car long on X or Z" use a world AABB from every part's 8 corners.
- **Rotating a model with `PivotTo` math is easy to get wrong.** One car ended up upside down. Rotate each part's CFrame around the model center instead, then check with a screenshot.
- **Collision for measuring:** store MeshParts are often `CollisionFidelity = Box`, so raycasts hit the bounding box. Set `PreciseConvexDecomposition` on a test copy to measure real shapes (works from `execute_luau`), then put it back.
- **Attachments:** set `Parent` before `WorldPosition`, or the position gets applied twice.
- **Invalid enums error out the whole chunk** (e.g. `Enum.Material.CorrugatedSteel` does not exist). Build into an unparented folder and parent at the end, so a failure leaves nothing half-built.
- **Big builds:** chunk the work and `task.wait()` between chunks, or Studio freezes and the MCP call drops.

## Assets
- **Decals from the store get the decal id, not the image id.** They render blank. Fix: `InsertService:LoadAsset(decalId)` in Edit mode and read the Decal's `Texture`. The image id is usually decal id minus a small number, but don't guess.
- **`upload_image` needs an http URL**, not a file path. Serve local files with a tiny local server (see the FPS vault Graffiti Generator note). It also needs a Claude Code permission rule for `mcp__Roblox_Studio__upload_image`.
- **`generate_mesh` rate limit:** firing 6 at once got 2 "Too Many Requests" failures. Retrying one at a time worked. `wait_job_finished` often times out on the first call; just call it again.
- **Inserted store models get their scripts sandboxed**, but the scripts are still there. Delete them. See [[70 Imports/Ultimate Slop Hub/wiki/tools/Store Asset Vetting|Store Asset Vetting]].

## Lighting
- **`Lighting.Technology` can't be set or read from a script** (needs higher security). Set it in the Properties panel by hand.
- **Lights only render near the real Studio viewport camera.** `screen_capture` from far away shows lamps with no light pools. Take night screenshots near where the viewport camera is, or move the viewport.
- **Tree canopies swallow streetlights** if the lights cast shadows. Streetlights have `Shadows = false`.
- **Temporarily changing `ClockTime` for daylight screenshots:** save it in an attribute first and restore it after. Team Create sees the change while it lasts.

## Playtests
- **Edit-only tools fail in Play mode** ("Edit datamodel is not available"). If Cade is playtesting, read the `Server` datamodel instead, or ask before stopping play.
- **Don't run screen captures in parallel.** They time out. One at a time.

## Related
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Studio MCP Reference|Studio MCP Reference]]
- [[70 Imports/Ultimate Slop Hub/wiki/tools/Store Asset Vetting|Store Asset Vetting]]
- [[70 Imports/Ultimate Slop Hub/wiki/index|index]]
