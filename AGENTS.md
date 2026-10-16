# O Blah Warfare (Roblox) - Codex rules

Read first every session:
1. Latest file in `Roblox Game Vault/08 AI Workflow/Session Logs/`
2. `Roblox Game Vault/01 Game Design/O Blah Warfare Design.md`
3. `Roblox Game Vault/08 AI Workflow/Two Dev Rules.md`
4. In Studio: `ServerStorage.README_CONTRACT` (the contract is law)

## Setup
- The game lives in Roblox Studio Team Create. This repo is the shared notes vault (Obsidian). Edit the game only through the Roblox_Studio MCP.
- Two devs: Cade (Claude Code) owns COMBAT; partner (Codex) owns GAME FLOW. Never edit outside the GAME FLOW area. Put requests in the contract or `06 Tasks/Next Pass.md`.

## Working style
- Inspect first, list what you'll change, wait for OK on anything big.
- One bounded task at a time. Playtest with start_stop_play + get_console_output, fix errors, report what was tested and what's left.
- Scope search_game_tree / script_grep to our folders, never the whole game.
- Use asset tools (search_asset, insert_asset, generate_mesh, generate_material) instead of building everything from basic parts. Delete all scripts inside inserted assets and report them. No store weapons or characters.
- End every session with a log in `Session Logs/YYYY-MM-DD-codex.md` and remind your dev to commit drafts.

## Code rules
- Luau, current APIs. `task.wait`/`task.spawn`/`task.delay`, never `wait`/`spawn`/`delay`.
- Server authoritative: never trust the client for hits, damage, kills, currency, purchases. Validate every RemoteEvent payload.
- Logic in ModuleScripts, thin Scripts. Names and folders follow the contract.
- No aligned `=` signs or trailing spaces (breaks multi_edit).
- Placeholder IDs for products/passes in one config module.

## Content
No real gang names, hand signs, real locations, gore, or blood. Cosmetic-only monetization, no pay-to-win, no paid random loot boxes.

## Talking to your dev
Short answers. Ask if unclear instead of guessing.
