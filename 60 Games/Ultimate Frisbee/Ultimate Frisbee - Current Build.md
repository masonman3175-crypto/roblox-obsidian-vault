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

## Power shop (added 2026-10-21, playtested)
Matches the existing HUD style (dark navy panels, purple outline, Gotham Black, pill gradient buttons).

| Script | Where | Job |
| --- | --- | --- |
| ShopConfig | ReplicatedStorage.ShopSystem | Catalog: 8 placeholder powers + 4 coin packs, prices, rarities, `thumbnail` and `productId` slots |
| Request | ReplicatedStorage.ShopSystem | RemoteFunction: `Buy` / `Equip` / `Unequip` + power id |
| ShopService | ServerScriptService | Owns coins and unlocks, validates every request, `award(player, amount)` for match payouts |
| ShopServer | ServerScriptService | Starts the service |
| ShopClient | StarterPlayerScripts | Coin wallet + SHOP button (top right), shop panel with Powers and Coin Packs tabs |

- **Player state:** `Coins` attribute, `EquippedPower` attribute (`""` = none), `OwnedPowers` folder of BoolValues. All set by the server.
- **For the powers side (partner):** read `player:GetAttribute("EquippedPower")` to know which power to give. Power ids are in ShopConfig.
- **Placeholders:** power names, initials-as-thumbnails ("ART SOON"), and every `productId = 0`, so the Robux buttons show "coming soon".
- **Studio test coins:** 2,500 in Studio, 0 live.
- **Tested:** open/close, select, buy with coins (2,500 → 1,500), equip/unequip, not-enough-coins message, Coin Packs tab, no console errors.

**Not done yet:**
- Coins aren't saved (no DataStore yet), so they reset when you rejoin.
- Matches don't pay coins yet. Call `ShopService.award` from RoundService on catch, score and win.
- No Robux handling: no Developer Products and no `ProcessReceipt` yet. That needs DataStore first so paid items can't get lost.

## Gaps vs the design
- No movement tech (sprint, slide, dive, dash)
- No powers
- No throw types or curve
- No real turnover rules: no possession switch, stall count or marking
- Code style: compressed one-line statements in RoundService/RoundRules (fine, but harder to diff)

## Related
[[Ultimate Frisbee - Game Hub]] · [[Ultimate Frisbee - Design]] · [[Ultimate Frisbee - Roadmap]]
