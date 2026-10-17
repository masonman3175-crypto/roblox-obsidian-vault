---
type: log
owner: shared
---

# Wiki Log

Append only, newest at the bottom. Entry header: `## [YYYY-MM-DD] op | Title (who)`.
Recent: `grep "^## \[" log.md | tail -5`

## [2026-10-16] setup | Vault set up as LLM wiki (claude)
- Added `raw/`, `wiki/` folders, [[index]], this log, devlog, `_templates/Reference Note.md`, `_templates/Devlog.md`
- Added Wiki schema to `CLAUDE.md` and `AGENTS.md`
- Added [[VFX Studio]] tool note

## [2026-10-16] update | Added weapons/ folder (claude)
- Schema in `CLAUDE.md`, `AGENTS.md`, and the Reference Note template now include `weapons/`

## [2026-10-16] ingest | First 5 references: guns, lighting, street (claude)
- raw: `2026-10-16-pink-sniper-skin.png`, `2026-10-16-color-grip-pistols-keyart.webp`, `2026-10-16-weapon-lineup.png`, `2026-10-16-night-porch-firefight.png`, `2026-10-16-overcast-rowhouse-street.png`
- New: [[Pink Sniper Skin]], [[Color Grip Pistols Key Art]], [[Weapon Lineup]], [[Night Porch Firefight]], [[Overcast Rowhouse Street]], [[Art Direction]]
- Updated: [[index]], [[2026-10-16]]

## [2026-10-16] update | Frequent pull/push rule (claude)
- Added git sync rule to `CLAUDE.md`, `AGENTS.md`, [[08 AI Workflow/Two Dev Rules|Two Dev Rules]]

## [2026-10-16] update | Attachments can be bought (claude)
- [[Weapon Lineup]]: recorded Cade's answer, flagged stat attachments must use earned currency, not Robux

## [2026-10-16] update | MCP connections tested, image rule (claude)
- Roblox Studio MCP: fixed launcher (full path to mcp.bat), 28 tools, finds open place. Noted in [[08 AI Workflow/Studio MCP Reference]]
- New [[Blender MCP]] tool note: tested scene read, reference image load, viewport look
- All 7 raw images verified intact on GitHub and readable by the AI (opened each one)
- Added "look at images, never guess from file names" rule to `CLAUDE.md` and `AGENTS.md`
- Index lists 3 partner raw files waiting for ingest

## [2026-10-16] ingest | Hood Warfare 2 reference pack (codex)
- New: [[Hood Warfare 2 Reference Pack]]
- Updated: [[index]]
- Added branches to art direction, map, weapon, VFX, Blender, and Studio workflow pages.

## [2026-10-16] update | Split Hood Warfare 2 pack into tiny pages (codex)
- New: [[Hood Warfare 2 Urban Routes]], [[Hood Warfare 2 Blockout Workflow]], [[Hood Warfare 2 Game Modes]], [[Hood Warfare 2 Combat Tuning]], [[Hood Warfare 2 HUD and Presentation]], [[Hood Warfare 2 Roblox Build Plan]]
- Updated: [[Hood Warfare 2 Reference Pack]], [[index]]
- Added small linked branches for maps, modes, combat, HUD, build order, and Roblox architecture.
