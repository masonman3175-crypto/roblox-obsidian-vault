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
  - You can equip up to 3 owned powers. They're stored in the `Loadout` attribute (comma list).
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

## Lobby HUD (2026-10-22): copies visual-refs/sports/Basketball-GUI.png
`StarterPlayerScripts.LobbyHUD` handles the lobby screen. It only shows when you're not in a match.
- **Left:** a 2-column grid of square neon tiles (icon and label), with a collapse arrow:

| Tile | Opens | Icon |
| --- | --- | --- |
| STORE | Store | glossy basket |
| POWERS | Power Shop | vault upgrade arrows, `75733335081970` |
| PASSES | Store's Passes tab | vault gold key, `132285102544675` |
| RAMEN | Ichi's Ramen | 🍜 |

  - PASSES shows a red "!" badge until the Starter Pack is bought.
  - Tiles call `ShopSystem.Open:Fire(shop, tab)`.
- **Bottom-left:** an orange-edged **LEVEL** box. Level is season tier + 1 (`MonetizationConfig.seasonTier`), and the side meter shows XP toward the next tier. Under it: a big coin and the gold coin count, on a fading dark strip. The top-right wallet chip is hidden.
- **Top-right, under the round bar:** the LEADERBOARD: LOBBY pill, then avatar, name and WINS for up to 8 players, refreshed every second.
- **Right:** the "Emote [G]" key hint (the partner's emote key).
- **Bottom-right:** dark bars, like the reference's "View Courts" and "Practice Court".
  - The partner's arena button (`ArenaTravelClient`) is now the **Practice Court** bar. RoundClient's own practice button is hidden.
  - RoundClient's Ready Up is a dark bar too, but the partner's speed mode hides it.
- **Nameplates:** a W-L record under each player's feet (BillboardGui on the HRP), shown in the lobby only.
  - `Wins` and `Losses` are new saved stats (ShopService data), counted at full time in RoundService.
- **Not built** (no real feature behind them): the reference's spinner, season pass, inventory, stats, clans, settings, "coins in 14:04" timer and server list.

## Shops pass (2026-10-22): one shell for three shops
- **One UI:** `ShopClient` is the single sports-neon shell (solid neon edges, 6px corners, dark panel, no pattern, no floating icon). The stall prompts open it:

| Prompt | Shop | Tabs |
| --- | --- | --- |
| `OpenPowerShop` | **Power Shop** | POWERS |
| `OpenStore` | **Store** | SKINS, PASSES, COINS |
| `RamenChat` (Ichi) | **Ichi's Ramen** | RAMEN |

  - `ReplicatedStorage.ShopSystem.Open` (BindableEvent) opens it from other UI. The partner's STORE button fires it.
  - The partner's old store panel no longer opens.
- **Skins:** come from `MonetizationConfig.Cosmetics`, sorted cheapest first. They show the coin price with the coin icon, plus a Robux button.
  - Buying and equipping go through `MonetizationSystem.Request` (`BuyCosmetic` / `Equip`).
  - Discs and trails without art get a color-swatch placeholder.
- **Passes:** Starter Pack R$15, 2x Coins R$29, VIP R$25. All Robux only.
  - VIP is now cosmetic: a gold VIP disc, VIP trail and the lounge. `VIPCoinBonus` = 0, since 2x Coins is the coin pass.
- **Coins:** Pouch 1,000 = R$10, Sack 3,500 = R$25, Chest 10,000 = R$49, Vault 30,000 = R$99. No bonus percentages.
- **Robux prices by rarity** (powers and skins): Common 5, Rare 10, Epic 15, Legendary 25, Mythic 39.
- **Ramen** (`ShopConfig.Ramen`):

| Bowl | Coins | Boost (next match) |
| --- | --- | --- |
| Shoyu | 30 | +25% |
| Miso | 60 | +50% |
| Spicy Tonkotsu | 120 | 2x |

  - One bowl at a time. `ShopService` `BuyRamen` sets the `RamenBoost` attribute, `award` applies it, and RoundService clears it at full time.
- **Not shown anymore:** the Anime Cup subscription, the season pass and the capsule. The capsule is a paid random roll, which breaks the "no paid loot boxes" rule. The partner's server code for them is still there.
- **Stalls:** the placeholder-icon back walls are gone.
- **Icons:** they're now placed inside a rarity glow instead of cropped. Real art is parked in [[Ultimate Frisbee - Parked Work]].

## Base movement (2026-10-22, second pass)
- **Bar (Valorant style), exactly 4 slots:**

| Key | Slot | Rule |
| --- | --- | --- |
| E | **High Jump** | default ability |
| F | **Dash** | default ability |
| C | shop ability | Common / Rare / Epic |
| X | shop ultimate | Legendary / Mythic |

  - The `Loadout` attribute is positional (`"<C id>,<X id>"`). Equipping a power replaces whatever is in its slot (`Config.slotFor`).
  - Super Saiyan is a shop ultimate. SaiyanService refuses Transform unless it's equipped, and the ability bar sends it from X.
- **Catch:** right-click (and X on a controller). The GRAB DISC key cap reads RMB.
- **Coins:** Studio tops up to 100,000 every join, for testing. New live players start with 5,000.
  - **Not built yet:** the first-join shop tutorial.
- **Run:** Roblox's Rthro run (`2510198475`), upright, for walk and run. Grass footsteps.
- **Jump:** the normal jump locks after leaving the ground, for 1.6s.
  - The High Jump flip now plays once (`Looped=false`) and stops on landing. It used to loop, which looked like jumping in place.
- **Dash:**
  - The client does the movement (72-speed burst) and fires `AbilitySystem.Dash`. The server stamps the `DashAt` attribute, rate-limited.
  - Every client then layers a low lunge pose on that character (extra joint rotations in `MovementClient`, the same method as `SaiyanPose`) and adds 3 white speed-line trails. So other players see it too.
- **Pivot:**
  - The holder has WalkSpeed 0, so there's no run animation.
  - The server IK pins the left foot on the ground under the plant spot (`PlantPosition` = pin).
  - The client turns the body around that foot to face the aim (hips sit 0.5 right of the foot), and WASD leans up to 1.2 studs.
  - Checked: the foot stays on its pin (0.07 studs off).

## Review fixes (2026-10-21, all 7 review findings)
1. **Shutdown:** `BindToClose` waits until every save finishes, up to 25s.
2. **Session lock:** each save records the server using it (a GUID plus a time), written with `UpdateAsync`.
   - A new server waits (10 tries, 3s apart) while another server still holds the save.
   - A lock older than 180s (a crashed server) is taken over.
   - A server never writes over a save another server took.
   - Leaving releases the lock, so a rejoin loads instantly (checked by stopping and restarting Play).
3. **Catch payouts:** only the first 10 catches per player per match pay coins, so passing back and forth can't farm them.
4. **Retries:** every DataStore call retries 3 times. Autosave now runs every 60s and refreshes the lock.
5. **SelfTests:** now covers saving with fake stores:
   - A failed load never writes.
   - A save held by another server is neither loaded nor overwritten.
   - A stale lock is taken over.
6. **Leaving mid-load:** a player who leaves during loading has the lock released and no state kept.
7. **`EquippedPower` removed:** nothing read it. `Loadout` is the only source.

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

- **Player state:** `Coins` attribute, `Loadout` attribute (comma list of up to 3 power ids), `OwnedPowers` folder of BoolValues. All set by the server.
- **For the powers side (partner):** listen to `ReplicatedStorage.AbilitySystem.Activated` (server) for `(player, powerId)`. Power ids are in ShopConfig.
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
