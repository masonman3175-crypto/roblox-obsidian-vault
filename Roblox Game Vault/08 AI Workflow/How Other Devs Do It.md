# How Other Devs Do It

Research summary, Oct 2026. Links in [[Sources]].

## The big pattern everyone converges on
1. **Plan in text first.** Design doc / GDD before any building. AI builds from the doc, not from vibes.
2. **Rules file the AI always reads** (CLAUDE.md for Claude, AGENTS.md for Codex). More conventions written = better output.
3. **Small bounded tasks.** One system per prompt. New chat when the topic changes.
4. **AI tests its own work** via MCP (playtest, read console, fix), but humans still playtest and review.
5. **Session logs.** AI writes what it did at the end of each session so the next session has memory.
6. **Code in files + git** (Rojo or Argon) once the project gets serious.

## SyphoDev: "How to Make a Roblox Game With AI (Claude Opus 5.5 Full Tutorial)"
138K views, Oct 2026. The most complete public workflow. Built whole games (code, UI, maps, VFX, sound, 3D models) with Claude Code.
- **Claude Code + custom skills.** A skill = a folder with `SKILL.md` (name, description, instructions) plus scripts and reference files. He has a `create-roblox-game` skill that runs research, design, and build in order, plus smaller skills per job.
- **Built-in Studio MCP** to connect Claude to Studio.
- **Rojo** so Luau code lives in real files (git-friendly).
- **Roblox Open Cloud API key** so Claude can upload models/images directly. Key stored in an env var / file, NEVER pasted into chat.
- **Stuff Claude can't make itself:**
  - Images/icons: Flux on Cloudflare Workers AI
  - 3D models: Hi3DGen on a free Kaggle GPU, then Blender to cut triangle count under Roblox limits
  - Uploads: Open Cloud API
- His skills are behind a paid course (about 20 GBP). He said he'd release them free at 1K subs. Not needed, we can write our own.
- Chapters: Claude Code (0:56), skills (1:41), MCP (4:00), models/APIs (5:31), setup (8:18), every skill (10:05), all together (23:36). Worth watching 1:41 to 10:05.

## DevForum: "What's your setup to use Claude Code?"
- **Use the MCP mostly to LOOK, not to playtest.** One dev says MCP playtests are slow, so he playtests himself while 2-3 Claude sessions work on separate tasks.
- **New chat per topic** = the #1 token/quality trick.
- **Plan in Claude chat first**, have Claude write a design doc, then start Claude Code fresh with that doc.
- **Session logs** at the end of every chat.
- **Point the AI at Roblox docs** (Studio MCP has `http_get` for official docs). Improves consistency.
- Pitfalls:
  - `multi_edit` fails when lines have invisible extra spaces (aligned `=` signs). Written into our rules.
  - Long sessions: `script_grep` can return stale/cached results. Restart the session.
  - Claude re-reads files a lot = burns tokens.
  - AI misses security stuff. Always ask for a RemoteEvent exploit review.
  - "Get all scripts" pulls in Roblox core scripts and blows up context. Always scope searches to our folders.

## DevForum: Hawknet ("We built a full game with 2 people using AI")
- Paid ($7.99/mo) third-party MCP. 2 devs + AI made a game with combat, skill trees, datastores, UI.
- Selling points: AI playtests itself, Luau type checking while writing, Rojo/Argon sync, undo snapshots, **multi-agent with file locking**.
- **Community called out sketchy stuff:** obfuscated code, exposed keys, unsigned Windows binary.
- **Verdict: skip it.** Roblox's built-in MCP is free, official, and has most of these tools now. The idea worth stealing is "file locking" = our ownership rules in [[Two Dev Rules]].

## Guides (obby.fun, clauder-navi)
- Start every task with an **inspection-only** request: "tell me which scripts/instances you would change." Then approve.
- One bounded change at a time. Playtest. Read output. Review.
- Prompt should include: game type, "Luau, current APIs," the feature from the player's view, exact Explorer paths, edge cases (death, rejoin, leaving mid-match).
- Rules file should list: Luau only, script naming, RemoteEvents for client-to-server, shared logic in ModuleScripts, DataStoreService for saves, `task.wait()`/`task.spawn()` not `wait()`/`spawn()`.
- Watch for deprecated APIs in AI output.
- Hybrid: MCP for exploring and quick tests, Rojo for stable code in git.

## Team Create + Drafts problem (DevForum feature request)
- AI agents **can't see Drafts**. One prompt can create dozens of uncommitted drafts, and the agent can't tell which code is actually live.
- Play Solo runs YOUR drafts. Team Test runs the committed server version.
- Workaround: commit drafts often; when confused, start a play session and check what code is actually running.
- Alternative: **Live Scripting** mode (edits go live for everyone immediately). Mutually exclusive with Drafts, set per place. See [[Two Dev Rules]].

## What this means for us
- Our setup (built-in MCP + vault + CLAUDE.md/AGENTS.md + ownership split) matches what people getting good results do.
- Biggest gaps right now:
  1. No CLAUDE.md / AGENTS.md in the repo. **(added this session)**
  2. No session logs. **(folder added this session)**
  3. AI isn't using assets/generation tools, so everything is blocky parts.
  4. Code lives only in Studio, not in files. Rojo later.
  5. No real design doc in the vault (Game Overview still describes the old keyboard demo).
