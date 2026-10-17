# Two Dev Rules

Cade (Claude Code) + partner (Codex) editing the same Team Create place.

## Ownership (the "file lock")
| Owner | Area |
|---|---|
| **Claude / Cade** | COMBAT: weapons, ADS, recoil, hit detection, damage, death, kill credit, killfeed, killstreaks. Later: progression, DataStores, monetization. |
| **Codex / partner** | GAME FLOW: teams, spawns, modes, capture zones, scoring, match timer, HUD, scoreboard, map. |

- Never edit the other side's scripts or folders. Need something from them? Write the request in the contract or [[06 Tasks/Next Pass]].
- The in-game contract `ServerStorage.README_CONTRACT` lists every folder, RemoteEvent, and module. It is law. Change it only together.

**Current assignment (2026-10-16):** Cade + Claude build the map, partner + Codex build guns. Assets only for now. Place: hood warfare 1.2 (`127865723083651`).

## Don't step on each other
- Tell each other in chat before starting a big AI task ("Claude is doing weapons rn").
- Only one AI session per person touching Studio at once.
- Drafts mode: AI can't see drafts. **Commit drafts at the end of every task**, otherwise your partner's Team Test runs old code.
- If something "doesn't work" after an AI change, first check: are the drafts committed?

## Vault (git)
- Pull and push **often**, not just at start and end. We edit at the same time.
- `git pull --rebase --autostash` before you start and before every commit.
- Commit + push right after every finished change (a note, an ingest, a log entry). AIs push without asking.
- Push rejected: pull with rebase, push again. Conflict you cannot fix cleanly: stop and ask. Never force push.
- Stay on `main`. `sync-vault.ps1` still works for a manual sync.
- Don't edit the same note at the same time. Session logs go in separate dated files so they never conflict.

## Hard rules for both AIs
- Server authoritative. Never trust the client for hits, damage, kills, currency, purchases.
- Logic in ModuleScripts, Scripts stay thin.
- Free/store assets: delete every script inside before using. No store weapons or characters.
- No real gang names, hand signs, real locations, gore, or blood (Roblox Community Standards). "OBlock" names are out.
- Monetization: cosmetic only, no pay-to-win, no paid random loot boxes.
