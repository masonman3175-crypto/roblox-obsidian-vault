---
type: system
owner: flow
status: shipped
sources: []
updated: 2026-10-17
---

# Zombie Lobby And Co-op Queues

Current user direction: **cooperative zombies**, replacing the previous PvP/menu flow in hood warfare 1.2 (127865723083651). Related: [[Main Street Block]], [[Game Audio And Music]], [[Current Test And Integration Backlog]].

## Latest lobby polish
[[Lobby Movement And Queue Circles]] adds lobby sprint/slide, selectable first/third person, removes the top banner and replaces the original four gates with eight circular queues. Use its current source archive; the first lobby installer is historical.

## Live flow
- Players arrive directly in the walkable Survivor Hub. The old PLAY/locker/gun-wrap menu is removed from active storage/scripts, not just covered by another GUI.
- Everyone belongs to **Survivors**, non-neutral. Previous split-team pads are disabled. The existing combat same-team guard is preserved.
- Solos / Duos / Trios / Squads are **1 / 2 / 3 / 4 cooperative players**, not opposing teams.
- Step into a colored queue area. A full party starts a 15-second countdown; stepping out cancels readiness. LEAVE blocks automatic rejoin until the player exits the pad.
- Every party deploys to the **same arena transform (0, 4.6, 0)** on the existing map. Other parties remain friendly on the same shared map; there are no separate PvP arenas.
- Lobby: sprint/slide/crouch, selectable first/third person, hidden/stashed weapons and protection. Deployment restores weapons and retains the selected camera view; V/button toggles views. M returns to the lobby; death respawns there after 2.5 seconds.
- No background music. Real lobby footfalls/jump/land audio remain enabled.

## Compact lobby and leaderboard
- Workspace.SurvivorLobby at X=1000; foundation 212x158 versus the main arena's 482x244 inner footprint.
- Eighteen copied existing-map models: rowhouses, corner store, laundromat, oaks and bus shelter. Copied scripts inspected/stripped: 0 found. Main-map buildings/routes are unchanged.
- Eight glowing walk-in circles (two per mode), floating per-circle counts/15-second timers, no top title banner, unobstructed arrival and session leaderboard with aligned columns.
- Leaderboard shows real server ZombieKills and measured best deployed-life duration. No zombie kill system exists yet, so zero kills are expected until combat integration supplies them. No fabricated wins/XP and no new persistence.

## Code and authority
- ReplicatedStorage.LobbySystem: Config, Client, Request (RemoteEvent).
- ServerScriptService.LobbySystem: Queue (pure kernel), Service, Boot; runtime tool stash and server-local QA Control.
- StarterPlayerScripts.SurvivorLobby is a thin bootstrap. Server membership is determined from actual live character position in the queue zone.
- Remote accepts only rate-limited Leave/Return with no extra arguments. Client does not choose join mode, destination, party membership or scores.
- Original menu objects/teams/spawn manifest/audio source live in ServerStorage.ZombieLobbyBackup_20261017.
- The initial lobby pass changed only the audio-owned Client outside new lobby sources. The current polish also changes the flow-owned movement client/server gates; combat/controller and audio source are not edited by that follow-up.

## Tested
- Fresh Client Play spawns directly in lobby, one team, no old menu/locker, no held/backpack weapons.
- Actual LEAVE button, no auto-rejoin until exit, queue switching, Solo countdown/deploy and measured exact shared pivot.
- Larger pads each wait for their full size with one real player. Pure queue tests launch full 1/2/3/4-member groups, cancel/restart, prune disconnected members and avoid duplicate dispatch.
- Real M return, lobby footsteps/no music, deployed W1 single-shot/reload, server rejection of malformed requests and leaderboard data.
- Two death/respawn cycles retain exactly five stashed weapons without duplication.
- 140 queue-floor rays, lobby/shared-spawn ground checks, source equality, complete installer syntax compile and actual isolated rollback pass. Street and final leaderboard captures visually inspected.

## Next work
- NPC zombie AI, waves, difficulty, zombie kill credit and survival round rules are **not built by this lobby task**.
- Same-server queues only; invitation parties/cross-server matching are not supplied.
- Simultaneous real 2/3/4-client launches, shared-spawn collision, audio/friendly-fire acceptance, touch/gamepad and performance still need testing.
- [[04 Scripts/Zombie Lobby And Co-op Queues/Implementation|Exact source, evidence and rollback]]. Commit Studio drafts; Git archive is not a public Roblox publish.
