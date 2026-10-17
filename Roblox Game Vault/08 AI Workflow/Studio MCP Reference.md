# Studio MCP Reference

Roblox's **built-in** Studio MCP server (official, free). Use this one, not third-party MCPs.
Source: create.roblox.com/docs/studio/mcp

## Setup (once per computer)
1. Studio > **Assistant** (unlabeled icon top-right, right of Share) > **...** > **Manage MCP Servers** > turn on **Enable Studio as MCP server**.
2. Connect the AI:
   - **Quick connect** (easiest): Assistant Settings > MCP Servers > Quick connect > turn on Claude Code / Codex / Claude Desktop.
   - **Claude Code CLI, Windows:** `claude mcp add --scope user Roblox_Studio -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`
   - **Claude Code CLI, Mac:** `claude mcp add --scope user Roblox_Studio -- /Applications/RobloxStudio.app/Contents/MacOS/StudioMCP`
   - **Codex, Windows:** `codex mcp add Roblox_Studio -- cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`
3. Restart Studio and the AI client. Green dot in Manage MCP Servers = connected.
4. Studio must be open with the place loaded for tools to work.

## Tools
| Group | Tool | What it does |
|---|---|---|
| Scripts | `script_read` | Read a script (whole or line range) |
| | `multi_edit` | Batch edits to a script; creates it if missing |
| | `script_search` | Find scripts by name (max 10) |
| | `script_grep` | Search text across scripts (max 50) |
| Assets | `search_asset` / `insert_asset` | Creator Store search + insert by ID |
| | `generate_mesh` | AI 3D mesh from text |
| | `generate_material` / `generate_texture` | AI materials/textures |
| | `generate_procedural_model` | Build object from parts (+ reference images) |
| | `upload_image` / `store_image` | Get images into Roblox |
| Explore | `search_game_tree` | Explorer hierarchy as JSON (filter by path/type/depth) |
| | `inspect_instance` | Properties, attributes, children of one instance |
| | `subagent` | Hand off to an `explore` or `playtest` subagent |
| Run | `execute_luau` | Run Luau in Edit/Client/Server |
| Playtest | `start_stop_play`, `get_studio_state`, `get_console_output`, `screen_capture` | Play, check state, read Output, screenshot |
| Input | `character_navigation`, `user_keyboard_input`, `user_mouse_input` | Drive the character during playtest |
| Docs | `http_get`, `skill` | Official Roblox docs + best-practice refs |
| Sessions | `list_roblox_studios` | Which Studio windows are connected |

## Tips
- **Claude Code on Windows, tested 2026-10-16:** use the full-path command above (`cmd.exe /c "%LOCALAPPDATA%\Roblox\mcp.bat"`). The Quick connect form `cmd.exe /c "cd /d %LOCALAPPDATA%\Roblox && .\mcp.bat"` failed: the `cd` doesn't stick, so `mcp.bat` isn't found and the server never answers. Working setup shows 28 tools and `list_roblox_studios` finds the open place.
- If 2 Studio windows are open, the AI must use `list_roblox_studios` and target the right one.
- Always scope `search_game_tree` / `script_grep` to our folders, not the whole game (core scripts eat context).
- `multi_edit` breaks on invisible extra spaces. Don't align `=` signs with spaces.
- Long sessions can return stale reads. Restart the session if things look wrong.
- `execute_luau` and `multi_edit` change the real place. Team Create autosaves to Roblox, so mistakes go live for both devs. Use **File > Version History** to roll back.
- Asset tools exist. If the AI is building everything from blocks, tell it to use them (see [[Prompt Templates]]).
