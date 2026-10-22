---
kind: game-build
game: ultimate-frisbee
status: prototype
updated: 2026-10-21
tags: [roblox, ultimate-frisbee, implementation]
---

# Ultimate Frisbee - Current Build

Audit of the Studio place (placeId `81684535279790`) as of 2026-10-21. Read from the scripts, not playtested yet.

## Scripts
| Script | Where | Lines | Job |
| --- | --- | --- | --- |
| FrisbeeConfig | ReplicatedStorage.FrisbeeSystem | 58 | Shared tuning + launch/flight math |
| DiscBuilder | ReplicatedStorage.FrisbeeSystem | 65 | Builds the disc model if missing |
| FrisbeeController | ServerScriptService | 184 | Server-authoritative hold / throw / flight / catch |
| FrisbeeServer | ServerScriptService | 4 | Starts the controller |
| FrisbeeClient | StarterPlayerScripts | 185 | Input, aim, charge UI |
| RoundRules | ReplicatedStorage.RoundSystem | 42 | Pure captain-draft and weather-vote rules |
| RoundService | ServerScriptService | 227 | Lobby → Vote → Draft → Warmup → Match flow, scoring, scoreboard |
| RoundServer | ServerScriptService | 3 | Starts the round service |
| RoundClient | StarterPlayerScripts | 175 | Round UI |
| WeatherService / WeatherClient | SSS / SPS | 46 / 47 | Rain, Night, Snow, Day |

Remotes: `FrisbeeSystem.Action`, `FrisbeeSystem.Feedback`, `RoundSystem.Action`, `RoundSystem.State`.
Backups in ServerStorage: `FrisbeeUIBackup`, `FrisbeeRevisionBackup`, `RoundSystemBackup`.

## World
- `FrisbeeStadium`: about 348 x 80 x 628 studs, ~21.8k parts (heavy, so watch performance on mobile)
- `SkylineLobby`, `MatchWeatherWorld`, `MatchDisc`, a leftover `Baseplate` and `SpawnLocation`
- Field bounds in code: X ±80, Z ±220 (1 yard = 4 studs)

## How play works now
- **Pick up:** walk within 4.8 studs of a loose disc, or use the prompt within 11.
- **Holding:** feet are planted (WalkSpeed 0, root anchored). You can only aim.
- **Throw:** hold Mouse1 / R2 / touch to charge (1.8s to full), release to throw. Speed 32-112 studs/s, gravity 17, horizontal drag 0.085. No curve yet.
- **Catch:** the disc auto-catches within 4.5 studs. Pressing E / X opens a 0.75s "hands ready" window with an 8-stud reach. The thrower can't self-catch for 1.15s. Catches are swept, so fast discs can't tunnel through players.
- **Turnover:** the disc lands or leaves the field and becomes loose. No possession rules yet: anyone grabs it.
- **Score:** a catch in the endzone gives +1, first to 5. Teams are Cyan and Pink.
- **Reset (R):** sends a loose disc back to midfield.

## Gaps vs the design
- No movement tech (sprint, slide, dive, dash)
- No powers
- No throw types or curve
- No real turnover rules: no possession switch, stall count or marking
- Code style: compressed one-line statements in RoundService/RoundRules (fine, but harder to diff)

## Related
[[Ultimate Frisbee - Game Hub]] · [[Ultimate Frisbee - Design]] · [[Ultimate Frisbee - Roadmap]]
