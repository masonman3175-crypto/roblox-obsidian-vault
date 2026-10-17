# O Blah Warfare (Roblox) - Codex rules

Read first every session:
1. Latest file in `Roblox Game Vault/08 AI Workflow/Session Logs/`
2. `Roblox Game Vault/01 Game Design/O Blah Warfare Design.md`
3. `Roblox Game Vault/08 AI Workflow/Two Dev Rules.md`
4. In Studio: `ServerStorage.README_CONTRACT` (the contract is law)
5. `Roblox Game Vault/wiki/index.md`, then the last 5 entries of `wiki/log.md`

## Setup
- The game lives in Roblox Studio Team Create. This repo is the shared notes vault (Obsidian). Edit the game only through the Roblox_Studio MCP.
- Two devs: Cade (Claude Code) owns COMBAT; partner (Codex) owns GAME FLOW. Never edit outside the GAME FLOW area. Put requests in the contract or `06 Tasks/Next Pass.md`.

## Working style
- Inspect first, list what you'll change, wait for OK on anything big.
- One bounded task at a time. Playtest with start_stop_play + get_console_output, fix errors, report what was tested and what's left.
- Scope search_game_tree / script_grep to our folders, never the whole game.
- Use asset tools (search_asset, insert_asset, generate_mesh, generate_material) instead of building everything from basic parts. Delete all scripts inside inserted assets and report them. No store weapons or characters.
- End every session with a log in `Session Logs/YYYY-MM-DD-codex.md` and remind your dev to commit drafts.

## Git sync (vault)
Both devs edit this vault at the same time, so sync constantly. No need to ask before pushing.
- `git pull --rebase --autostash` at session start and before every commit.
- Commit and push right after every finished change (a note, an ingest, a log entry). Small commits, clear messages.
- Push rejected? Pull with rebase again, then push.
- Merge conflict you cannot resolve cleanly: stop and ask your dev. Never force push or rewrite pushed history.
- Work on `main`. No long-lived branches.
- Skip noise: do not commit `.obsidian/graph.json` or `.obsidian/workspace*.json` changes.

## Code rules
- Luau, current APIs. `task.wait`/`task.spawn`/`task.delay`, never `wait`/`spawn`/`delay`.
- Server authoritative: never trust the client for hits, damage, kills, currency, purchases. Validate every RemoteEvent payload.
- Logic in ModuleScripts, thin Scripts. Names and folders follow the contract.
- No aligned `=` signs or trailing spaces (breaks multi_edit).
- Placeholder IDs for products/passes in one config module.

## Content
No real gang names, hand signs, real locations, gore, or blood. Cosmetic-only monetization, no pay-to-win, no paid random loot boxes.

## Wiki schema (LLM-wiki pattern)
Based on Karpathy's LLM-wiki gist. The AI keeps a compounding wiki of what we learn (references, techniques, tools) so we never re-research the same thing. Same section lives in `AGENTS.md`; change both together.

All paths below are inside `Roblox Game Vault/`.

### Layers
- `raw/` = sources. Reference images, screenshots, clips, clipped pages, plugin docs. **Immutable**: read, never edit, rename, or delete. Name new files `YYYY-MM-DD-short-name.ext`. Obsidian attachments land here.
- `wiki/` = AI-owned pages. Humans read, AI writes and keeps it linked.
  - `ui/` menus, HUD, scoreboards, UI feel
  - `vfx/` muzzle flash, tracers, hit effects, particles, beams, post-processing
  - `maps/` layouts, lighting, environment art
  - `systems/` gameplay mechanics and how they work
  - `tools/` Studio plugins and outside tools we use
  - `weapons/` gun models, skins, attachments, gun feel (owner: combat)
  - `devlog/` one file per day, `YYYY-MM-DD.md`: what changed in the game, in plain words
  - `index.md` = catalog of every wiki page
  - `log.md` = append-only timeline of wiki work
- This section = the schema.
- `_templates/` = note templates (Obsidian Templates plugin points here).
- Old folders `01`-`08` stay as they are. `index.md` links them. Move them into `wiki/` only during a lint pass and only with an OK.

### Page rules
- Reference notes use `_templates/Reference Note.md`. Every reference note must fill "How we'd build it in Roblox" with real Instances, services, and where the code would live per the contract.
- Frontmatter on every page: `type` (reference / tool / system / map / ui / vfx / weapon / devlog), `owner` (combat / flow / shared), `status` (idea / planned / building / shipped / dropped), `sources` (list of `raw/` files or URLs), `updated` (YYYY-MM-DD).
- One topic per page, Title Case file names. Link with `[[wikilinks]]`. Every page links to at least one other page and is listed in `index.md`.
- Ownership still applies: only edit pages whose `owner` is your side or `shared`. Put requests for the other side in `06 Tasks/Next Pass.md`.
- Mark guesses as `(unverified)`. Never invent plugin features, asset IDs, or API behavior.
- Same content rules as the game: no real gang names, hand signs, real locations, gore, or blood.

### Operations
- **Ingest** ("ingest raw/X"): one source at a time. Read it (open images directly, embedded images are not visible when reading text). Give 3-5 takeaways and the pages you'd touch, wait for OK. Then write or update the reference note, update related pages, update `index.md`, append to `log.md`.
- **Query**: read `index.md` first, then the pages it points to. Answer with `[[links]]`. If the answer is worth keeping (a comparison, a build plan), file it as a wiki page and log it.
- **Lint** ("lint the wiki"): check for contradictions, stale claims, orphan pages, broken links, pages missing from `index.md`, `raw/` files never ingested, and concepts that deserve their own page. Report, fix small stuff, ask before big moves, log it.
- **Devlog**: when a game change ships, add a bullet to today's `wiki/devlog/YYYY-MM-DD.md` (create from `_templates/Devlog.md`). Session Logs in `08 AI Workflow/` are still the per-AI-session handoff; devlog is the human-readable game history.

### log.md format
Append only, newest at the bottom. Each entry starts with:
`## [YYYY-MM-DD] op | Title (who)` where op is ingest / query / lint / setup / update and who is claude or codex. Then 1-3 bullets: pages touched. Recent work: `grep "^## \[" log.md | tail -5`.

### index.md format
One line per page under its folder heading: `- [[Page]] - one-line summary (status)`. Update on every ingest, new page, rename, or delete.

## Talking to your dev
Short answers. Ask if unclear instead of guessing.
