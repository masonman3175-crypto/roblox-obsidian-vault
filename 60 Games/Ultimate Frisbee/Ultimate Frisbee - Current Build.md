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

## Power shop (added 2026-10-21, rebuilt same day, playtested)
**Style:** sports-neon, from `Roblox References/Source/visual-refs/sports/` (Main-Menu, Football-Main-Menu, Basketball-GUI):
- near-black tiles with their own neon border and glow
- Sarpanch Heavy headings, Oswald Bold labels
- tag ribbons sitting on the top edge, a square SHOP tile with a cart icon, and a gold wallet

The first version (dark purple pills) was rejected as bland.

- **Icons:** coin image `rbxassetid://16047279971` (decal 16047279995, cartoon coin, transparent background). Cart image `rbxassetid://79771344090455` (decal 94946111287810). Decal IDs don't load in ImageLabels; get the image ID with `game:GetObjects("rbxassetid://DECAL")[1].Texture`.
- **Rarity effects** (UI only; particles don't render in ScreenGuis, so the VFX Studio plugin is for 3D effects later):

| Rarity | Effects |
| --- | --- |
| Common | none |
| Rare | shine sweep |
| Epic | + spinning border + glow |
| Legendary | + rotating light rays + pulsing glow |
| Mythic | + rainbow border + rising sparkles |

- **Unlock reveal** (the "10x" pass). It scales with rarity:
  1. **Blackout:** the screen goes dark and the 3D world desaturates.
  2. **Charge-up:** a shrinking ring and orb climb through the rarity colors (Common → up to the real rarity), with light streaks pulling in, the camera FOV zooming and a growing shake.
  3. **Impact:** a white flash, a world color grade in the rarity color, an FOV kick, and 1-3 shockwave rings.
  4. **Burst:** two counter-rotating ray layers, sparks, and a confetti rain (Legendary/Mythic).
  5. **Text:** "LEGENDARY!" slams in from 3x size (rainbow on Mythic), then the power name, then "TAP TO CONTINUE".
- **Buy buttons:** coin price and Robux price sit side by side under COINS / ROBUX headers. The "BEST DEAL" tag was removed.
- **Coin pack art tiers:** 1,000 = one coin, 3,500 = a stack, 10,000 = a stockpile (image `85434636773071`), 30,000 = a vault door (`918689343`) with an overflowing chest (`108290137907113`). Each has spinning light rays behind it.
- **Shared style:** `ReplicatedStorage.UIStyle` has the palette, the fonts, `glow()`, and `pattern()` (color wash + drifting diagonal stripes + halftone dot corner). ShopClient and RoundClient both use it.
- **Lobby restyle:** RoundClient (lobby panel, round bar, weather chip, weather cards, draft) now uses the UIStyle helpers. Only its look changed; the logic is untouched.
- **Prices:** coins went up and Robux went down. Rule: buying a power directly with Robux is always cheaper than buying coin packs for it.

| Rarity | Coins | Robux |
| --- | --- | --- |
| Common | 1,000 / 1,500 | 25 / 35 |
| Rare | 3,000 / 4,000 | 59 / 69 |
| Epic | 7,500 / 9,000 | 99 / 119 |
| Legendary | 15,000 | 179 |
| Mythic | 25,000 | 249 |

Coin packs: 1,000 = R$29 · 3,500 = R$89 · 10,000 = R$219 · 30,000 = R$549.

- **Color scheme (2026-10-21), defined in `UIStyle.C`:**
  - **Blue** = structure: every panel edge, tabs, primary buttons, the SHOP tile, the round bar.
  - **Gold** = currency only: coins, wallet, pack ribbons.
  - **Lime** = confirm/go: BUY with coins, READY UP.
  - **Red** = close/danger.
  - **Cyan/pink** = team colors only.
  - **Rarity colors** only on power art.
  - Surfaces are `ink`, then `panel`, then `raised`.
- **Top bar:** the round bar, wallet pill (a big coin overlapping a soft gold-edged pill) and SHOP tile sit in one row on wide screens. Below 1100px wide, the wallet and SHOP tile drop to a second row.
- **Coin art is all cartoon now:** coin, stack, coin pyramid, treasure chest with coins. The realistic pile and vault were removed.
- **Reveal shake** is softened: smooth noise instead of pixel jitter, about a third of the old strength, and a smaller FOV punch.
- **Weather choice removed:**
  - The server's Vote phase lasts 0s, weather is random each match, and the `Vote` request is rejected.
  - The 4 lobby weather pads and their 4 signs are removed from `SkylineLobby` (moved to `ServerStorage.LobbyWeatherPadsBackup`, so they can be restored). The wall subtitle now reads "READY UP • DRAFT TEAMS • EQUIP POWERS".
  - The lobby panel shows match info tiles (mode, to win, weather random, powers) instead of weather cards, and the weather chip is hidden.
- **Loadout + ability bar (Valorant style):**
  - You can equip up to 3 owned powers. They're stored in the `Loadout` attribute (comma list); `EquippedPower` mirrors slot 1.
  - Keys are Q / F / C. E is catch, so it's not used.
  - `AbilityClient` draws the bar at bottom center: slot art, rarity stripe, key cap, cooldown sweep with seconds, a pop when ready, and a ready pulse. It hides while the lobby or shop is open.
  - `AbilityService` (server) validates the slot, ownership, alive state and cooldown (by rarity: 10 / 12 / 14 / 18 / 25s, or `power.cooldown`). It publishes the `Ready_<id>` attribute and fires `ReplicatedStorage.AbilitySystem.Activated(player, powerId)`.
  - **For the powers side:** connect to that event on the server to make each power actually do something. Right now pressing a key only starts the cooldown.
  - **Known conflict:** the partner's Super Saiyan transform also uses Q. It should become a power in the bar.
## Audit fixes (2026-10-21, all 12 audit findings)
1. **Self-catch:** the thrower can never catch their own throw. `SelfCatchDelay` was removed from FrisbeeConfig.
2. **R reset:** only works in Solo Practice; it's refused mid-match.
3. **Saving and coin payouts:**
   - **Saving:** ShopService saves coins, owned powers and loadout to DataStore: `PlayerShop_v1` live, `PlayerShop_Studio` in Studio. It saves on leave, on server close, every 120s, and after each buy.
   - **Failed loads:** a load that fails 3 times means that session plays unsaved and never overwrites the real save.
   - **Payouts** (from RoundService, Match only): catch +5, goal +25, win +50, everyone else in the match +20.
   - **Studio:** to test saving, turn on Game Settings → Security → "Enable Studio Access to API Services". It's off right now, so Studio sessions play unsaved.
4. **Robux guard:** the server refuses to start if any `productId` is not 0, until ProcessReceipt exists.
5. **Abilities in the lobby:** AbilityService only accepts presses when you're in a Match or Practice.
6. **Q conflict:** Super Saiyan moved from Q to **X** and is drawn as the ultimate slot in the ability bar.
7. **Vote code removed:** from RoundService, RoundRules (`tally` / `winner` / `validWeather`) and RoundClient (weather cards, chip, `canVote`). The draft now goes straight to warmup.
8. **Saiyan stamina:** only replicates in steps of 5.
9. **Self-test:** `ServerScriptService.SelfTests` covers the draft rules and shop buy/equip/loadout rules. Run it in Play on the server with `require(game.ServerScriptService.SelfTests).run()`; it passes.
10. **Shared helpers:** `UIStyle.make` / `glow` / `HEAVY` / `BOLD` are shared by ShopClient, RoundClient and AbilityClient.
11. **Reveal leak:** effect lists drop entries whose UI is gone.
12. **Leftovers:**
    - The disabled default SpawnLocation was deleted.
    - The Baseplate is kept, since it's the ground under the stadium.
    - The ServerStorage backups are kept.

## Lobby and copy pass (2026-10-21)
**Rule (Cade):** no explanatory UI copy. That means no taglines, no hints that restate a button, no info screens on join, and no footers. Labels and real content only.

- **Lobby panel removed.** RoundClient was rewritten:
  - The top status bar stays.
  - Left-side buttons are always reachable: **READY UP** (lime; becomes "READY" when on) and **SOLO PRACTICE** / **LEAVE PRACTICE**. Practice shows only when you're the only player.
  - The **captain draft panel** shows only during the draft (with blur), with title, turn line, teams and pick list.
  - **Results** show as a non-blocking banner under the top bar.
  - Back To Bay is gone; Leave Practice replaces it.
- **Copy cut:**
  - **Shop:** the subtitle, the coins-page note, the "ART SOON" tags, and the COINS/ROBUX headers over the buy buttons.
  - **Reveal:** "TAP TO CONTINUE".
  - **Throw meter:** the HOLD/RELEASE hint.
- **Wallet:** now the same chip shape as every tile (panel fill, blue edge, glow, coin inside, gold amount), 49px tall to line up with the round bar and SHOP tile.
- **SHOP icon:** the glossy basket from `visual-refs/icons/Glossy Pink Shopping Basket Icon.png`, uploaded as `rbxassetid://83548623877440` (`Config.CartImage`).
- **10,000 pack:** a glossy overflowing coin bag (decal 135012121024011 → image `110884906766263`).

## Bottom HUD layout (one style, no overlaps)
- **Ability bar** (bottom center, in-game only): Q / F / C shop powers, then a gap, then the **X** ultimate slot (Super Saiyan). A thin sprint-stamina line sits above the slots.
- **Throw/catch card** (FrisbeeClient) sits just above the bar. It uses the shared palette: the meter ramps blue → cyan → lime → gold, the GRAB DISC button is blue, and the key caps match the ability bar.
- **Super Saiyan:** its old gold box is hidden. Its P menu, touch buttons and toast use UIStyle, and the toast now shows under the top bar.
- **Draw order:** the shop draws above the partner's `SaiyanClient` power HUD (`DisplayOrder` 100).

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
- **Studio test coins:** 30,000 in Studio, 0 live.
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
