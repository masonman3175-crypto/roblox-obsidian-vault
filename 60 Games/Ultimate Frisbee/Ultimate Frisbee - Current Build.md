---
kind: game-build
game: ultimate-frisbee
status: prototype
updated: 2026-10-23
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

## Spec pass (2026-10-22): built to [[Ultimate Frisbee - Basketball GUI Spec]]
- **Fonts:** only two now.
  - `Style.HEAVY` = Gotham Bold for labels, buttons and titles. `Style.BOLD` = Gotham Medium for names.
  - **`Style.NUM`** = Oswald Bold for every number: level, coins, wallet, leaderboard values, cooldown seconds and nameplate level.
- **`Style.dress(o, color, radius, color2)`**:
  - a dark fill in the tile's own color, and an outer outline in that same dark color
  - a bright 2px border fading `color` → `color2`
  - a glow
  - no white inner line
- **`Style.neonIcon`:** an icon with a faint larger copy behind it as a glow.
- **Tiles:**

| Tile | Border fades |
| --- | --- |
| STORE | red → orange |
| POWERS | purple → pink |
| PASSES | pink → purple |
| RAMEN | orange → yellow |

- **Collapse arrow:** a navy square with a light gray border and a blue-violet chevron.
- **Level box:** near-black brown with an orange-brown border, a white condensed number, an orange "LVL" label and an orange meter.
- **Leaderboard:** a navy header with a light-blue title and orange stat, a gray LOBBY pill, and dark rows. **Rows update in place** now, which fixes the blinking (it used to rebuild every second).
- **Bottom-right bars** (Ready Up, Practice Court): plain near-black navy with a faint edge, like the reference.
- **Nameplate:** a dressed frame in the equipped plate's color, with a dark inner panel holding the level (Oswald) and the name (Gotham).

## Dressed look pass (2026-10-22)
- **`UIStyle.dress(o, color, radius)`** is the basketball-reference look:
  - a color gradient fill
  - a black outer edge (3px)
  - a color rim (2px)
  - a thin white inner line
  - a soft glow

  A button's own text moves to a child `DressText` label, since gradients tint text. It's used by the lobby tiles, collapse arrow, level box, leaderboard header and emote key, the Ready Up and Practice Court bars, GRAB DISC, the ability slots, and every shop button and wallet.
- **Fonts back to sporty:** `Style.HEAVY` = Sarpanch Heavy and `Style.BOLD` = Oswald Bold. The partner had switched them to BuilderSans.
- **Nameplate:** smaller (4.4 × 1.05 studs). It shows a **level badge** and name only (no W-L), styled by the equipped **Nameplate** cosmetic.
  - New kind in `MonetizationConfig.CosmeticKinds`: Gold, Sakura (Rare), Inferno, Toxic (Epic) and Galaxy (Legendary) plates, sold in Store → Skins.
- **Top bar in speed mode while waiting:** "WAITING FOR PLAYERS" and "Round starts when a player joins", instead of "SPEED FRISBEE / WARM UP".
- **GRAB DISC:** the separate shadow frame is gone (it didn't follow the hover pop).
- **Cooldowns:** a blue-tinted fill drains away with a cyan scan line on its top edge, and a bigger count with a blue outline.
- **Not checked:** the nameplate while the partner's Titan test is active. It turns every player into a giant model that hides the plate.

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
- **Not shown anymore:** the Anime Cup subscription and the season pass. The capsule was replaced by anime summons (2026-10-23, see below).
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

## Skins pass (2026-10-22)
- **Disc skins look real now:** `MonetizationClient.applyDisc` recolors the disc, puts the skin's image on top (`SkinTop`), adds a rim outline and sparkles. Sakura is white with flowers, Galaxy is a galaxy, Ice Crystal is tinted icy blue.
- **Skin images** live in `MonetizationConfig` (`image`, optional `tint`, `rim`, `sparkle`). Shop tiles draw the same images.
- **Nameplates:** Sakura Plate has flowers, Galaxy Plate is a nebula. The plate shows `wins NAME losses` (green / red), fades out past ~28 studs and hides in a game.
- **Trails** now show as a trail on the player (rainbow works), not only on the thrown disc.
- **Teams:** a cyan or pink ring under each player in a game. Jerseys stay as skins.
- **Lobby tiles:** STORE, POWERS, LOADOUT (opens MY POWERS to pick equipped powers), PASSES, RAMEN (new bowl icon). Collapse arrow removed.
- **Ramen icon:** Cade's bowl art with an even dark plus white outline, `rbxassetid://106701095190894` (source `raw/2026-10-22-ramen-icon.png`).
- **No shop in a game:** shops won't open while in a match or warmup and close when one starts.
- **Not checked:** the nameplate and ring from another player's view (Studio screenshots don't show billboards). Small shop plate tiles still wrap the sample text.

## Loadout, emotes and stadium pass (2026-10-22)
- **Slot types:** every power has a `slot` in `ShopConfig` (E jump/throw, F movement, C defense, X ultimate). `Loadout` is now positional `"E,F,C,X"`. E and F fall back to High Jump and Dash when empty (`AbilityClient`). Old 2-slot saves re-sort themselves on load.
  - E: Rasengan, Water Breathing, Gravity Pull. F: Flash Step, Shadow Clone, Thunder Dash. C: Infinity, Wind Slash, Ice Burst. X: Super Saiyan, Titan, Dragon Aura, Time Stop.
  - Shop cards show the key in a small chip; the detail line reads e.g. `EPIC / E JUMP / THROW`.
- **LOADOUT tile** opens a LOADOUT shop mode with POWERS and EMOTES tabs. The power shop only sells now.
- **Emotes:** free emotes (Freestyle, Wave, Point) are real `MonetizationConfig` cosmetics with `free=true`. LOADOUT > EMOTES toggles which ones are on the wheel (max 6, at least 1). Saved as `profile.emoteWheel`, published as the `EmoteWheel` attribute; `MonetizationConfig.emoteWheel()` is the shared rule.
- **EMOTES tile** on the left opens the wheel (G still works). The wheel uses the tile style. The right-side "Emote G" label and the extra EMOTES buttons are hidden.
- **HUD:** Practice Court has 4px corners like the tiles. Nameplate W / L are plain white. Ramen icon drawn bigger.
- **No more mystery labels:** the top "SPEED FRISBEE" box only shows when it has something to say (waiting for players, draft, etc.). Every "Skyline" sign now says ULTIMATE FRISBEE (disc stamp: ULTIMATE). The two deck name signs moved to `ServerStorage.RemovedSigns`.
- **Walk around the stadium:** the sky deck now opens onto the existing upper concourse ring. Glass rails (same look as the deck's) run along both edges all the way round, with invisible 8-stud colliders, in `StadiumUpgrade.Concourse`.
- **Crowd:** 2,276 blocky fans became one pill each (Rocket League style, team colours), tagged `CrowdFan`. `CrowdAnimator` bobs them and makes the scoring side jump. The old crowd is in `ServerStorage.CrowdBlocky`.
- **Not checked:** walking the full ring in play, and other players' views. The rest of the stadium (facade, canopies, city) is unchanged.

## Anime summons (2026-10-23)
Replaces the hidden Mystery Disc Capsule. Cade's call: the cool cosmetics come from RNG, not a buy button.
- **Open it:** new **SUMMON** tile in the lobby (red "!" when you have a ticket) opens the shop shell in `Summon` mode. One tab per banner:

| Banner | Kinds | Coins | Robux |
| --- | --- | --- | --- |
| DISCS | DiscSkin | 2,000 | R$10 |
| TRAILS | Trail | 2,000 | R$10 |
| PLATES | Nameplate | 1,500 | R$10 |
| EMOTES | Emote | 1,500 | R$10 |
| EFFECTS | ThrowFX + Celebration | 2,500 | R$15 |

  Prices are placeholders. Each banner has its own `productId` (0 = Robux button says "coming soon").
- **Odds** (`MonetizationConfig.SummonRarityOdds`): Common 50, Rare 30, Epic 14, Legendary 5, Mythic 1. Each rarity's share is split evenly between that banner's items. The right side of the banner lists every item with its exact %.
- **Pool:** every cosmetic of the banner's kinds that isn't `free` or `exclusive`. Adding a cosmetic to `M.Cosmetics` puts it in its banner automatically. A startup check asserts odds add to 100 and each banner has an Epic+.
- **Direct buy:** only Common and Rare keep `coins`/`robux`. Epic, Legendary and Mythic are summon-only (Store > Skins hides them).
- **Pity:** `SummonPity = 10`. The 10th summon in a row without an Epic+ rolls only Epic/Legendary/Mythic. Saved per banner in `profile.pity`, shown as "EPIC+ IN N" (`Pity_<key>` attribute).
- **Duplicates:** turn into coins (Common 150, Rare 300, Epic 700, Legendary 1,500, Mythic 4,000), shown in the reveal and odds panel.
- **Tickets:** free summon ticket every 3 matches + season track rewards. Saved as `capsuleTokens` (old name kept for saves), shown as `SummonTickets`.
- **Server** (`MonetizationService`): `Summon` (banner key, "Ticket"/"Coins") and `PromptSummon` (Robux, prompted by the server). Coin and Robux summons are refused where `RandomItemsRestricted` is true; the client hides those buttons (fails closed). Robux receipts roll the banner and fire `Notify("Summon", result)` so the client plays the reveal.
- **Saves are batched:** `saveSoon` saves at most once every 3s per player.
- **Reveal:** the existing rarity reveal plus two spinning magic circles from the VFX Studio texture library (`127817121` outer, `102790439571584` inner) that open up, speed up and climb the rarity colors during the charge. Bottom line: `NEW / NAME` or `NAME / DUPLICATE +X COINS`. You can't start another summon until the reveal closes.
- **New items (24):** discs Lime, Sky (C), Ocean (R), Neon Pulse (E), Kitsune Flame (M, fire texture `883906867`); trails Mint, Bubblegum (C), Toxic (E), Dragon Spirit (M, 3-color gradient); plates Steel, Mint (C), Celestial (M, magic-circle art); emotes Laugh, Shrug, Clap (C), Salute, Tilt (R), Disco, Happy (E), Hype Dance (L), Breakdance (M) (all official Roblox animations, checked with GetProductInfo); effects Spark Release, Confetti Goal (C), Supernova Goal (M). Prism Disc is now a Legendary in the disc banner.
- **Trails** can have `colors={...}` for a gradient (`MonetizationConfig.trailColor`, used by LobbyHUD and MonetizationClient).
- **Emotes** with `loop=false` now stay one-shot (EmoteController).
- **Tested:** 15 disc summons (coin charge, dupes, pity reset on Epic), one summon on each other banner, ticket with none, bad banner, Robux with no product. UI screenshots of the banner and the reveal. No console errors.
- **Not done:** x10 summon, real Robux product IDs, a 3D summon portal in the lobby, the Mythic effects look the same as other effects (only color differs).

## Crates + skins rework (2026-10-23, second pass)
Cade's feedback on the first summon version: the magic circles had nothing to focus on, too short, the ticket button was confusing, "summon" didn't read, and skins/summons should live together. Rebuilt:
- **Name:** summons are **crates** in the UI (DISC CRATE, TRAIL CRATE, PLATE CRATE, EMOTE CRATE, EFFECT CRATE). Code keeps the `Summon` names.
- **One SKINS shop:** the lobby **SKINS** tile (and the store stall prompt) opens `Skins` mode with tabs DISCS, TRAILS, PLATES, EMOTES, EFFECTS, JERSEYS. Store mode is now just COINS and PASSES.
  - Left: the crate card: a slowly spinning 3D crate (neon edges in the crate color), the two rarest items hidden as glowing "?" orbs with their %, rarity odds chips, ODDS button (full per-item list overlay), "EPIC OR BETTER IN N", OPEN (coins) and R$ buttons.
  - Right: every item of that type. Owned: EQUIP / EQUIPPED (emotes: ON WHEEL). Common/Rare: coin price, tap twice to buy (BUY? confirm). Crate-only and not owned: "???" mystery card, status CRATE.
  - This also fixes crate wins not being equippable anywhere.
- **No ticket button:** with a free ticket the OPEN button says FREE (or FREE x2).
- **Opening (`ReplicatedStorage.ShopSystem.CrateOpening`):** blur + desaturate, the 3D crate drops in, shakes harder and harder with rays building behind it, the lid blows off (flash, shockwaves, sparks), then a reel of 58 cards (weighted by the real odds, Legendary/Mythic shown as "?") spins past a gold marker for ~5.5s and slows down. 60% of non-Legendary rolls stop right before a Legendary/Mythic card (near miss). A mystery card shakes before it cracks. Then the reveal: rays, shockwaves, sparks, confetti (Legendary+), the rarity slam, the item name and NEW! or DUPLICATE +coins. About 12s total. Tap to close after the reveal, auto-closes after 10s.
- **Item art (`ReplicatedStorage.ShopSystem.ItemPreview`):** discs are real 3D discs (3 cylinders + skin decal; spinning in the reveal), emotes play on **your own avatar** in the reveal, nameplates show your name, trails/effects/jerseys are drawn. The magic circles are gone.
- **Tested:** Skins page screenshots (discs, emotes), a full emote crate opening, a forced Mythic opening (landed on a mystery card, avatar breakdancing in the reveal), no console errors.

## Sound pass (2026-10-23)
- **UI:** Roblox's official RBLX UI set: hover (every button, new), select (click), back (close), swipe (tabs), purchase (confirm), delete (shop errors, `Deny`).
- **Footsteps (MovementClient):** the old looping grass recording is muted (default Running/Jumping/Landing sounds forced to volume 0). Now one random sample per step, timed to speed (`4.6/speed`, 0.2-0.55s), random pitch 0.93-1.07, soft set on grass/dirt/sand/snow and hard set on everything else, a heavier double step on landing, a swish on jump. Other players' steps are quieter and 3D. Checked: 8 steps over 1.6s of running at speed 24.
- **Crate sounds:** whoosh in, thud land, rattles while shaking, wood break + deep boom on burst, a tick for every card passing the marker, stop click, then a rarity sting (Common/Rare: purchase chime, Epic/Legendary/Mythic: APM stings + boom), NEW / duplicate chime, close.
- **Sound Lab (Studio only):** `StarterPlayerScripts.SoundLab` puts a SOUND LAB button at the top of the screen in Studio. It lists cues with numbered alternates (`AudioConfig.Alts`, the starred one is current). Cade listens and picks; then swap the ids in `AudioConfig`.
- Voice limits raised (UI 6, total 14) so crate layers don't cut each other.
- **Not verified:** how any of it actually sounds (Claude can't hear). Footstep samples are user uploads (grass: Robloxmastermanyay, hard: Diman_x86).

## Gaps vs the design
- No movement tech (sprint, slide, dive, dash)
- No powers
- No throw types or curve
- No real turnover rules: no possession switch, stall count or marking
- Code style: compressed one-line statements in RoundService/RoundRules (fine, but harder to diff)

## Related
[[Ultimate Frisbee - Game Hub]] · [[Ultimate Frisbee - Design]] · [[Ultimate Frisbee - Roadmap]]

## Feedback pass (2026-10-23, third)
- **Reveal music removed** (felt corporate). Epic/Legendary/Mythic now use the purchase chime at rising pitch + the deep boom. Sound Lab: dropped Click 3, Close 2, CrateBurst 2 (too loud). Confirm 1 stays.
- **Emote previews:** a plain gray R15 rig (`ShopSystem.EmoteDummy`, built from a default HumanoidDescription) plays each emote in the shop cards and the reveal.
- **Mystery items** are now dressed tiles in the rarity color with a white "?" (same look as the lobby tiles), everywhere.
- **Disc rarity FX in game:** Epic+ discs glow (PointLight in rim color), Legendary+ add a soft aura (VFX Studio flare `9841273835`), Mythic adds flames (`1058335870`). Rarer disc trails glow brighter and last longer.
- **Player trails:** textured energy band (VFX Studio `magic_band` `1379899761`), brighter/longer by rarity.
- **Waiting on Blender:** new crate model, new disc models (Kitsune, Gold Rush, Neon Pulse called ugly), a real SKINS tile icon (now a galaxy texture, placeholder).
- **Idea (Cade):** a full cutscene for Legendary/Mythic pulls. Not built.
