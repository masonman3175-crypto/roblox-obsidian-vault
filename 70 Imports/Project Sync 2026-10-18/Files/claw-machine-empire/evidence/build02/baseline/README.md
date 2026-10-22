# Claw Machine Empire — Build 01: First Catch

An original, server-authoritative Roblox vertical slice built from your claw-arcade brief. **This is a playable alpha, not the full launch game.**

## Play

The confirmed Studio place **Place1** contains the installed build. Press **Play**.

Alternatively, open `Claw Machine Empire.rbxlx` in Roblox Studio and press Play. Its world is generated at runtime. `INSTALL.luau` also installs the same seven sources plus an Edit-mode scene preview into an empty namespace through Studio's Command Bar. Do not run the installer twice.

1. Press **PLAY RUSTY**. You begin with three free plays; one refills every 12 seconds.
2. Aim with **WASD / arrows** or the four on-screen direction buttons. Press **Space / DROP**. The first duck is centered. Other rounds generate nine server-chosen plushie targets; aim within 1.4 studs to catch one. There is no paid random draw.
3. The inventory opens after a catch. Press **DISPLAY** to put it on a shelf.
4. Shelf income accumulates in the **bank**, not your wallet. Press **COLLECT**.
5. Open **MACHINES** and unlock Classic for **250 earned coins**. A duck alone earns this in approximately 50 displayed seconds. This is fast alpha balance; the brief's $25K is not the current price.
6. Upgrade servo speed or shelf income. Stow and sell spare plushies to free inventory; discovery remains in the index.

## What exists

- Two working cabinets: Rusty and Classic. A clearly labeled Neon preview bay is not playable.
- Six original, part-built plushies: Goofy Duck, Mochi Bunny, Disco Frog, Bubblegum Dino, Space Cat, Pocket Supernova.
- Server-integrated aim, bounded duration, drop animation, miss/catch resolution, free refill, unique item IDs.
- Forty inventory spaces, eight display slots, collection index, stow/sell, income bank, two upgrades with four levels each.
- Private authoritative profiles, per-player plots (four active players), own-plot interaction bounds, input validation and token bucket.
- Nonnegative `{m,e}` scientific money, including values beyond native float range. Approximately 15 significant digits; this is not exact financial accounting. Small additions can round away at huge magnitudes. Exponent bound: ±1,000,000.
- Responsive desktop/tablet/phone UI, isolated shop preview, no external art or sound dependencies.

## Save modes and commerce

**Studio uses session-only data** and clearly labels it. Stopping Play resets the test arcade and does not contact live player data.

Outside Studio, `ProfileStore` uses the separate `ClawEmpire_Build01_v1` DataStore with `UpdateAsync` ownership leases, serialized saves, save snapshots, load validation, renewal, final release and fail-closed expiry. Backend behavior was tested using fault injection; a published staging experience, actual DataStore reconnect/outage tests and multi-client contention tests remain before release. No silent default profile overwrites a failed load.

**All Robux purchases are disabled.** Product IDs are zero, prices are not fabricated, the shop says “not for sale,” and unresolved receipts return `NotProcessedYet`. The cosmetic catalog is a schema, not a finished live commerce implementation. Changing `PurchasesEnabled` alone does not enable checkout. Before live sales, implement atomic durable receipt grants, pass reconciliation and current-price retrieval, then test retries/replays and relevant platform requirements.

## Source map

| Location | Responsibility |
|---|---|
| `src/shared/Config.luau` | Balance, original species, machine availability, closed catalog |
| `src/shared/BigNumber.luau` | Serialized scientific arithmetic and formatting |
| `src/shared/Economy.luau` | Pure validated item/currency transitions |
| `src/server/World.luau` | Original procedural cabinets, plushies, displays and animation poses |
| `src/server/ProfileStore.luau` | Injected persistence adapter and session ownership |
| `src/server/Bootstrap.server.luau` | Real remotes, rounds, player lifecycle and saves |
| `src/client/Main.client.luau` | Responsive HUD, aim controls, panels and camera |

## Rebuild / verify

From this project directory, using Python 3.10+ (tested with Python 3.14.6):

```powershell
python tools/build.py
python tools/verify.py baseline
python tools/verify.py modified
python tools/verify.py rollback --test
```

The builder regenerates the place, installer, Studio rollback, pure Luau test runner, diff and SHA-256 manifest. `tests/RUN_IN_STUDIO.luau` runs the pure modules against the actual Roblox Luau runtime in Edit Command Bar without mutating the place. See `evidence/VERIFICATION.txt` for exact observed results and limitations. Local XML/source checks do not by themselves prove engine gameplay.

## Rollback

`ROLLBACK.sh --test` exercises restoration **on a temporary copy**, checks unrelated-file preservation and later-edit protection, and leaves the delivered place changed. On Windows use Git Bash, or run the Python rollback test above.

`ROLLBACK.sh` without `--test` restores **only the local packaged place** to the retained empty-script baseline fixture, provided its delivered hash still matches. It does not operate Studio. To remove the installed Studio build, stop Play and run `STUDIO_ROLLBACK.luau` in Edit Command Bar. That removes only the new namespaces and restores captured lighting/camera properties; existing Baseplate/SpawnLocation remain. Live Studio rollback was exercised and the build reinstalled.

`evidence/BASELINE.json` records actual pre-install Studio state. `evidence/BASELINE.rbxlx` is a reproducible empty-script packaging fixture, **not an export of the original Place1 geometry**. The original Studio instances were retained in place rather than replaced.

## Next build

Neon progression, merge variants, shelf expansion, Arcade Ascension, deeper physical cabinet transformations, original audio, stronger reveal cinematics, live persistence staging and multiplayer/device-input hardening. The other eight machine tiers and the broad draft monetization catalog are not implemented yet. No game was published.

## Coding-robot handoff

```text
Continue Claw Machine Empire Build 01 from the existing seven Luau sources.
Read README.md, the user's unchanged references/Original Game Design.md,
and evidence/VERIFICATION.txt first. Keep the Rusty-to-Classic loop working.
Implement the next small vertical slice, not all roadmap features at once.
Keep rewards, IDs, wallet mutations, play refill and progression server-owned.
Preserve separate Studio test data and fail-closed profile ownership.
Keep real purchases off until a complete durable commerce path is tested.
Rebuild generated artifacts, rerun Luau contracts and actual Studio playtests,
check phone portrait/landscape and tablet layouts, and update the Obsidian
Build Log with observed results and remaining work. Never label placeholders
or mock-backend tests as live production validation.
```

## Primary implementation references

- [Client-server boundary validation](https://create.roblox.com/docs/scripting/security/client-server-boundary) — authority and hostile remote inputs.
- [Player data and purchasing systems](https://create.roblox.com/docs/cloud-services/data-stores/player-data-purchasing) — save ordering, session ownership and failure states.
- [MarketplaceService](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService) — unresolved receipt behavior; commerce remains disabled.

Your four visual references and full design text are preserved under `references/`. They informed the palette, cabinet/plushie mood and chunky UI, not copied game assets. Project notes are also in the existing Obsidian vault under **60 Games / Claw Machine Empire**.
