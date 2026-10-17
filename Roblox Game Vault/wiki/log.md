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

## [2026-10-16] update | Map pass 1: Main Street Block (claude)
- New: [[Main Street Block]], 4 screenshots in `raw/2026-10-16-map-pass1-*.jpg`
- Built in Studio (hood warfare 1.2) from [[Overcast Rowhouse Street]], [[Night Porch Firefight]], [[Hood Warfare 2 Urban Routes]]
- Updated: [[index]], [[2026-10-16]], Home place info, assignment note in rules files

## [2026-10-16] update | Map pass 2: facade grime (claude)
- Updated [[Main Street Block]] with pass 2 notes and 3 screenshots (`raw/2026-10-16-map-pass2-*.jpg`)
- Updated: [[index]], [[2026-10-16]], session log

## [2026-10-16] update | Map pass 3: real prop meshes (claude)
- Updated [[Main Street Block]] (template table, asset ids, pivot gotcha) + 3 screenshots `raw/2026-10-16-map-pass3-*.jpg`
- Updated: [[index]], [[2026-10-16]], session log

## [2026-10-16] update | First-person weapon import and polish (codex)
- Updated [[2026-10-16]] and [[08 AI Workflow/Session Logs/2026-10-16-codex|Codex session log]] with the Blender import, animated arms, Compact AK sight fix, pistol presentation and recoil tests.
- Map/spawns unchanged; all five weapon presentation tests pass. Damage/audio remain pending.

## [2026-10-16] ingest | Graffiti refs + map pass 4 fixes (claude)
- raw: `2026-10-16-graffiti-ref-*.webp` (3), `2026-10-16-graffiti-generated/` (13 PNGs + generator), `2026-10-16-map-pass4-*.jpg`
- New: [[Graffiti Style]]. Updated: [[Main Street Block]], [[Art Direction]], [[index]], [[2026-10-16]]

## [2026-10-16] update | Original graffiti uploaded and placed (claude)
- [[Graffiti Style]]: 13 image ids, 2 in-game screenshots. Updated [[Main Street Block]], [[index]], [[2026-10-16]]

## [2026-10-16] update | Lighting pass 1 (claude)
- New: [[Lighting And Atmosphere]] + 2 screenshots. Updated [[Main Street Block]], [[index]], [[2026-10-16]]

## [2026-10-16] update | Night lighting variant (claude)
- [[Lighting And Atmosphere]]: Night preset, LightingPresets module, 2 screenshots. Updated [[index]], [[2026-10-16]]

## [2026-10-16] update | Documented everything from the map session (claude)
- New: [[Map Tools]], [[Map Asset Registry]], [[Studio MCP Gotchas]], [[Store Asset Vetting]], [[Graffiti Generator]], [[Main Street Routes and Cover]]
- Updated: [[index]], Home dashboard, [[Main Street Block]] links, [[2026-10-16]]

## [2026-10-16] update | Map pass 5: hood not ghost town (claude)
- Updated [[Main Street Block]] (pass 5), session log, [[2026-10-16]]

## [2026-10-16] update | Pass 6 + Map VFX Library (claude)
- New [[Map VFX Library]]. Updated [[Main Street Block]], [[index]], session log

## [2026-10-16] update | Main menu, locker and aerial map view (codex)
- New [[Main Menu And Locker]], immutable main-menu reference image and source mirrors in 04 Scripts/Main Menu Source.
- Updated [[index]], [[2026-10-16]] and Codex session log. Tested four skins, six wraps, five previews, direct deploy, validation, respawn and isolated rollback; existing spawn transforms retained.

## [2026-10-16] ingest | 9 refs: FP guns, UI, VFX, skins (claude)
- New: [[First Person Gun Feel]], [[Neon Sniper Skin And HUD]], [[Custom Shop UI]], [[Stylized VFX References]]
- Updated: [[VFX Studio]] (install steps, how Claude uses it), [[index]]

## [2026-10-16] update | VFX Studio installed, vetted, used (claude)
- Updated [[VFX Studio]], [[Map VFX Library]] (retextured + gun VFX templates)

## [2026-10-16] update | Chainable slides and map perimeter (codex)
- New [[Sprint Slide And Map Boundary]] and source/test mirrors in 04 Scripts/Movement And Boundary Source.
- Updated [[index]], [[2026-10-16]] and Codex session log. Verified three chained slides, lower camera/restoration, 20-second sprint budget, wall collision, 840 gap checks and isolated rollback; original spawns retained.

## [2026-10-16] update | Claude AK: model, firing feel, server damage (claude)
- New [[Claude AK]]. Updated [[index]], [[2026-10-16]], session log, 06 Tasks/Next Pass

## [2026-10-16] update | Open-vault sync and missing implementation archive (codex)
- Added [[Gameplay HUD]], [[HUD Minimap]], [[HUD Ammo And Weapon Display]], [[HUD Scores And Feed]], [[Weapon Build Archive]], [[Obsidian Vault Sync]], [[Current Test And Integration Backlog]] and [[00 Dashboard/Game Development Hub|Game Development Hub]].
- Updated [[index]], Home and [[2026-10-16]]; archived the missing Blender/FBX/import/polish files, earlier prototypes, HUD source and a read-only live source snapshot. Preserved newer [[Claude AK]] integration rather than overwriting it.
- Synced the actual open Obsidian checkout with the shared repository; original local files/settings preserved in backup/stashes. Vault-only task: no Studio gameplay edits or new gameplay test claims.
## [2026-10-16] update | Claude AK v2 model: real proportions + baked PBR (claude)
- Updated [[Claude AK]] (model v2, texture ids)

## [2026-10-16] update | Claude AK installed in game (claude)
- Updated [[Claude AK]] (installed, offsets, status shipped)

## [2026-10-17] update | Ground finish and diagonal team spawns (codex)
- Updated [[Main Street Block]], [[index]], [[2026-10-17]] and Codex session log for the confirmed property-only ground/spawn change.
- Archived baseline, installer, tests, verification and isolated rollback in [[04 Scripts/Ground And Team Spawns/Implementation|implementation evidence]].
- Both actual PLAY deployments/protection expiry, 162 spawn samples and 1590 floor rays passed. Live update retained after isolated restore test.
## [2026-10-17] update | Game audio and 25 percent music (codex)
- New [[Game Audio And Music]] and source/test/asset archive; updated [[index]], [[2026-10-17]] and Codex session log.
- All 14 sounds load; all five weapon shot/reload tests, movement/idle, hit confirmations, real F8, cancellation, teardown/restart and isolated rollback passed.
- Existing nine inspected source strings unchanged; simultaneous two-client listening remains a follow-up.

## [2026-10-17] update | Crouch, compact map, floor repair and quiet music (codex)
- New [[Crouch And Compact Map]] and implementation/source/test archive; updated [[Sprint Slide And Map Boundary]], [[Main Street Block]], [[Game Audio And Music]], [[index]], devlog and session log.
- Verified 1.55-stud crouch eye drop, speed 8, six-cycle recovery, headroom, slide chains, crouched combat, both spawns, death/menu resets, 900 wall rays and 242 pad rays. Floor pairs 12 -> 0; music 5%.
- Isolated rollback restored original geometry/source fingerprints; unrelated dynamic-lighting error handed to map owner.
## [2026-10-17] update | Latest game work synchronized to Obsidian (codex)
- Updated [[00 Dashboard/Game Development Hub|Game Development Hub]], [[Current Test And Integration Backlog]] and [[index]] so current crouch, compact boundary, floor repair, team pads and 5% music are visible from the entry points.
- Verified 52 archived implementation/source/test/evidence files against local originals: all SHA256 hashes match across the three latest bundles. Historical snapshots remain labeled; personal settings and unrelated notes are preserved.
- Vault-only sync; no new Studio edits, gameplay tests or public publish claimed.

## [2026-10-17] update | Restore sound effects without background music (codex)
- Updated [[Game Audio And Music]], [[Crouch And Compact Map]], [[Current Test And Integration Backlog]], [[00 Dashboard/Game Development Hub|Game Development Hub]] and [[index]]; archived the effects-only repair, baseline, exact tests and rollback.
- Fixed deleted-music startup dependency. Fresh Client Play: 12 effects decode, all five guns one shot cue/reload each, real movement/idle, confirmations/death, validation, cancel and restart 65 ->65 pass. Music/mix/button absent.
- Retested after concurrent native gun updates; only audio-owned sources changed. Isolated rollback restores original broken baseline while live repair remains.

## [2026-10-17] update | Claude Beretta in W3 (claude)
- New [[Claude Beretta]]. Updated [[index]], [[2026-10-17]], session log

## [2026-10-17] update | Beretta hands back to Roblox-blocky (claude)
- Updated [[Claude Beretta]] (hands style rule)

## [2026-10-17] update | Curb z-fight fix and dynamic lighting (claude)
- Updated [[Main Street Block]], [[Lighting And Atmosphere]], [[Store Asset Vetting]]
- Devlog [[2026-10-17]], session log 2026-10-17-claude

## [2026-10-17] update | Co-op zombie lobby and queues (codex)
- New [[Zombie Lobby And Co-op Queues]] and source/scene/test/rollback archive. Updated design direction, retired [[Main Menu And Locker]], hub/index/backlog, [[Main Street Block]], [[Game Audio And Music]], tasks, devlog and session log.
- Physical compact lobby, session leaderboard, cooperative 1/2/3/4-player queues, one Survivors team and shared spawn. Verified fresh join, actual Leave/M return, Solo deploy, larger waiting pads, pure full-group dispatch cases, audio/combat/respawn and 140 floor rays.
- Original menu/teams/spawns/audio restore on isolated copies; live co-op lobby retained. No zombie AI/waves, persistence or cross-server matching claimed; multiplayer acceptance remains.

## [2026-10-17] update | Gritty lighting retune (claude)
- Updated [[Lighting And Atmosphere]]
