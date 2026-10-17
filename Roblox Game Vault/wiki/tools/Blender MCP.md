---
type: tool
area: tools
owner: shared
status: building
sources:
  - https://github.com/ahujasid/blender-mcp
updated: 2026-10-16
tags: [tool, mcp, blender, modeling]
---

# Blender MCP

Lets the AI drive Blender: read the scene, run Python, look at the viewport, import assets. Third-party (not made by Blender or Roblox). We use it to model guns and props from `raw/` references, then export to Studio.

## Verified (2026-10-16, Cade's PC)
- Blender 5.2.2, add-on "MCP for Blender" v1.8 installed and enabled.
- Server: `blender-mcp` 1.30.0 via uvx, using Python 3.12 (uv's own Python download hit a bug, so it points at the system Python 3.12).
- 9 tools: `get_addon_status`, `disable_telemetry`, `get_scene_info`, `execute_blender_code`, `record_trajectory_feedback`, `look`, `generate_3d`, `search_assets`, `import_asset`.
- Tested: `get_scene_info` read the scene, `execute_blender_code` loaded [[Pink Sniper Skin]] as a reference image, `look` returned a viewport screenshot.

## Every Blender session
1. Open Blender.
2. 3D view: press **N** > **BlenderMCP** tab > **Connect** (port 9876).

## Modeling from a reference
1. Open the `raw/` image yourself first (see the image rule in CLAUDE.md / AGENTS.md).
2. Load it as a reference: `execute_blender_code` with an Image Empty pointing at the `raw/` file.
3. Model over it, check with `look` often.
4. Export FBX/OBJ, import to Studio as MeshParts. Keep each gun split into parts (see [[Weapon Lineup]]).

## Rules
- `execute_blender_code` runs any Python. Save the .blend before letting the AI work.
- The add-on has telemetry and premium features (unverified what they send). Run `disable_telemetry` once if you care.
- No store or ripped gun models. Our own or generated meshes only.

## Partner setup (Codex)
Same steps: install Blender, uv, Python 3.12, the add-on from the GitHub repo, then `codex mcp add blender -- uvx --python <path to python.exe> blender-mcp`.

## Related
- [[VFX Studio]]
- [[08 AI Workflow/Studio MCP Reference]]
- [[index]]
