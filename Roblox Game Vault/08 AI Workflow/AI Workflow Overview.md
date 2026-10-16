# AI Workflow Overview

How the Claude + Codex + Roblox Studio + Obsidian setup fits together.

## The 4 pieces
| Piece | What it is | Where it lives |
|---|---|---|
| **Roblox Studio (Team Create)** | The actual game. Scripts, map, UI. | Roblox servers. Follows you to any PC automatically. |
| **Studio MCP** | Bridge that lets an AI read/edit/playtest the open place. | Built into Studio. Runs locally, so set up once per computer. |
| **AI clients** | Claude Code (Cade), Codex (partner). | Each dev's own machine. |
| **This vault (GitHub repo)** | Plans, rules, notes, references, task lists. The AI's long-term memory. | GitHub, cloned on each PC. |

## How a work session goes
1. `git pull` (or run `sync-vault.ps1`) so the vault is current.
2. Open Studio with the place loaded. Check the MCP indicator is green.
3. Start the AI in the vault folder. It reads `CLAUDE.md` / `AGENTS.md` automatically.
4. Give it ONE bounded task (see [[Prompt Templates]]).
5. It inspects first, says what it will change, then edits, then playtests and reads the console.
6. You playtest yourself. Review what changed.
7. AI writes a short session log in `08 AI Workflow/Session Logs/` and updates [[06 Tasks/Next Pass]].
8. Commit + push the vault.

## Why the vault matters
AI sessions forget everything when they end. The vault is what carries over:
- **Rules** (CLAUDE.md, AGENTS.md, the in-game `README_CONTRACT`)
- **Design** (what the game is, modes, weapons, look)
- **State** (what's built, what's broken, what's next)
- **Logs** (what each session did, so the next one doesn't redo or break it)

Without this, each new session guesses and rebuilds stuff from scratch. That's the "it's so ass" problem.

## Moving between computers
- Game: nothing to do, it's on Roblox.
- Vault: `git clone` once per PC, then `git pull` / push every session.
- MCP: redo once per PC. See [[Studio MCP Reference]].
- Mac MCP path is different from Windows (see that note).

See also: [[How Other Devs Do It]], [[Two Dev Rules]], [[Sources]].
