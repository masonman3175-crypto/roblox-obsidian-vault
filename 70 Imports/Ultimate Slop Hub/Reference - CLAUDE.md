# Ultimate Slop Hub (Roblox) - Claude Code rules

One vault for every quick homepage-style game Cade and partner make (simulators, obbies, tycoons). Shared blueprint, shared wiki, one folder per game. Same section lives in `AGENTS.md`; change both together.

Read first every session:
1. Latest file in `Session Logs/`
2. `blueprint/Slop Blueprint.md` (the recipe every game follows)
3. `blueprint/Monetization And Compliance.md`
4. The game's folder in `games/<Game>/` (Design.md, Next Pass.md)
5. In Studio: `ServerStorage.README_CONTRACT` of that place (layout from `blueprint/Studio Layout.md`)
6. `wiki/index.md`, then the last 5 entries of `wiki/log.md`

## Setup
- Each game is its own Roblox place. This repo is the shared notes vault (Obsidian). Edit games only through the Roblox_Studio MCP.
- Two devs: Cade (Claude Code) and partner (Codex). Usually one dev per game. Whoever starts a game owns it (`games/<Game>/Design.md` says who). Don't edit the other dev's game without asking; put requests in that game's `Next Pass.md`.
- The FPS game "hood warfare 1.2" (`127865723083651`) lives in the other vault (`roblox-obsidian-vault`) and is paused. Never touch it from here.
- **Source mirror:** Studio is the source of truth, but after every script change export every script to `games/<Game>/src/` with the [[70 Imports/Ultimate Slop Hub/wiki/tools/Script Mirror|Script Mirror]] tool (`python tools/mirror_server.py "<Game>"` in the background, then the execute_luau snippet on that page) and commit + push. The folder, the vault, and the game stay in one place.
- Before any Studio edit: `list_roblox_studios` and make sure the target is the right place. If more than one Studio is open, ask.

## Working style
- Speed matters: these games ship fast. Build the loop first, polish later.
- Inspect first, list what you'll change, wait for OK on anything big (new systems, deleting things, uploads).
- One bounded task at a time. Playtest with start_stop_play + get_console_output, fix errors, report what was tested and what's left.
- Scope search_game_tree / script_grep to our folders, never the whole game.
- Use asset tools (search_asset, insert_asset, generate_mesh, generate_material) instead of building everything from basic parts. Delete all scripts inside inserted assets and report them (see [[70 Imports/Ultimate Slop Hub/wiki/tools/Store Asset Vetting|Store Asset Vetting]]). No store characters.
- End every session with a log in `Session Logs/YYYY-MM-DD-claude-<game>.md` and remind Cade to commit drafts / publish.

## Git sync (vault)
Both devs edit this vault at the same time, so sync constantly. No need to ask before pushing.
- `git pull --rebase --autostash` at session start and before every commit.
- Commit and push right after every finished change (a note, an ingest, a log entry). Small commits, clear messages, prefix with the game: `stat-sim: ...`, `hub: ...`.
- Push rejected? Pull with rebase again, then push.
- Merge conflict you cannot resolve cleanly: stop and ask your dev. Never force push or rewrite pushed history.
- Work on `main`. No long-lived branches.
- Skip noise: do not commit `.obsidian/graph.json` or `.obsidian/workspace*.json`.

## Code rules
- Luau, current APIs. `task.wait`/`task.spawn`/`task.delay`, never `wait`/`spawn`/`delay`.
- Server authoritative: never trust the client for stats, currency, purchases, rebirths, zone unlocks. Validate every RemoteEvent payload and rate-limit training remotes.
- Logic in ModuleScripts, thin Scripts. Folders follow `blueprint/Studio Layout.md` and the place's `README_CONTRACT`.
- No aligned `=` signs or trailing spaces (breaks multi_edit).
- All gamepass / dev product IDs live in one config module (`ReplicatedStorage.Shared.Config.Monetization`). Placeholder `0` until the real IDs exist.
- DataStore: one profile per player, retries with backoff, save on leave + `BindToClose` + autosave. Never lose data to a failed load (don't overwrite on load failure).

## Content
No real gang names, hand signs, real locations, gore, or blood. No other games' IP, brands, or real people. Monetization follows `blueprint/Monetization And Compliance.md` (stat boosts are allowed in these games; deceptive design is not).

## Wiki schema (LLM-wiki pattern)
Based on Karpathy's LLM-wiki gist. The AI keeps a compounding wiki of what we learn (homepage game breakdowns, systems, monetization patterns, tools) so every new slop game is faster than the last. The wiki is shared across all games on purpose.

### Layers
- `raw/` = sources. Screenshots of homepage games, clips, clipped pages, docs. **Immutable**: read, never edit, rename, or delete. Name new files `YYYY-MM-DD-short-name.ext`. Obsidian attachments land here.
- `wiki/` = AI-owned pages. Humans read, AI writes and keeps it linked.
  - `references/` breakdowns of other games (one page per game or per screenshot set)
  - `systems/` mechanics and how we build them (stats, training, rebirth, zones, data saving)
  - `monetization/` gamepasses, dev products, shop placement, pricing patterns
  - `ui/` HUD, shop, popups, leaderboards, UI feel
  - `maps/` towers, obbies, zones, lobby layouts, lighting
  - `vfx/` level-up pops, particles, number popups, juice
  - `tools/` Studio MCP, Blender MCP, plugins, outside tools
  - `devlog/` one file per day, `YYYY-MM-DD.md`: what changed in which game, in plain words
  - `index.md` = catalog of every wiki page
  - `log.md` = append-only timeline of wiki work
- `blueprint/` = the recipe and hard rules every game follows. Change only with Cade's OK.
- `games/<Game>/` = per-game design doc and task list.
- `_templates/` = note templates (Obsidian Templates plugin points here).
- This section = the schema.

### Page rules
- Reference notes use `_templates/Reference Note.md`. Every reference note must fill "How we'd build it in Roblox" with real Instances, services, and where the code lives per `blueprint/Studio Layout.md`.
- Frontmatter on every page: `type` (reference / system / monetization / ui / map / vfx / tool / devlog / game), `game` (hub for shared, or the game folder name), `owner` (cade / partner / shared), `status` (idea / planned / building / shipped / dropped), `sources` (list of `raw/` files or URLs), `updated` (YYYY-MM-DD).
- One topic per page, Title Case file names. Link with `[[wikilinks]]`. Every page links to at least one other page and is listed in `index.md`.
- Mark guesses as `(unverified)`. Never invent plugin features, asset IDs, prices, or API behavior.
- **Look at images, never guess from file names.** Before you describe, ingest, or model from anything in `raw/`, open the actual image file with your image tool (Claude Code: Read the file. Codex: `view_image`). If you cannot open it, say so and stop. Every reference note embeds its image and has a written breakdown, so text-only readers still get the details.
- **Modeling from a reference:** Blender MCP: load the `raw/` image as an Image Empty with `execute_blender_code`, then check with `look`. Studio MCP: `generate_procedural_model` and `upload_image` can take a reference image, but `upload_image`/`store_image` upload to Roblox, so ask first.

### Operations
- **Ingest** ("ingest raw/X"): one source (or one screenshot set of the same game) at a time. Open every image. Give 3-5 takeaways and the pages you'd touch, wait for OK. Then write or update the reference note, update related pages, update `index.md`, append to `log.md`.
- **Query**: read `index.md` first, then the pages it points to. Answer with `[[links]]`. If the answer is worth keeping (a comparison, a build plan), file it as a wiki page and log it.
- **Lint** ("lint the wiki"): check for contradictions, stale claims, orphan pages, broken links, pages missing from `index.md`, `raw/` files never ingested, and concepts that deserve their own page. Report, fix small stuff, ask before big moves, log it.
- **Devlog**: when a game change ships, add a bullet to today's `wiki/devlog/YYYY-MM-DD.md` (create from `_templates/Devlog.md`), tagged with the game. Session Logs are the per-AI-session handoff; devlog is the human-readable history.

### log.md format
Append only, newest at the bottom. Each entry starts with:
`## [YYYY-MM-DD] op | Title (who)` where op is ingest / query / lint / setup / update / build and who is claude or codex. Then 1-3 bullets: pages touched. Recent work: `grep "^## \[" log.md | tail -5`.

### index.md format
One line per page under its folder heading: `- [[Page]] - one-line summary (status)`. Update on every ingest, new page, rename, or delete.

## Talking to Cade
Shortest answers possible. Ask if unclear instead of guessing. No em dashes. He's new to Luau, so explain fixes in one plain line.
