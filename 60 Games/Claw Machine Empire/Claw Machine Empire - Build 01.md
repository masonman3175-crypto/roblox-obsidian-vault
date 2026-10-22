---
kind: build-log
game: claw-machine-empire
status: verified-studio-alpha
tags: [roblox, claw-empire, implementation, verification]
---

# Claw Machine Empire — Build 01: First Catch

Parent: [[Claw Machine Empire - Game Hub]] · Next: [[Claw Machine Empire - Build 02 Backlog]]

## Implemented

| System | Actual behavior |
|---|---|
| Claw rounds | Server-owned aim integration, bounds, 25-second round, 2.6-second drop, target-radius catch/miss |
| Free plays | Three stored, one refill per 12 seconds; no paid attempts |
| Machines | Rusty and Classic; Classic unlock costs 250 earned coins in this alpha |
| Plushies | Six original procedural models; Common through Mythical |
| Inventory | Unique IDs, 40-item cap, display/stow/sell, retained discoveries |
| Shelves | Eight slots; one item per slot; displayed species generate bank income |
| Wallet | Manual bank collection, validated spending, serialized scientific money |
| Upgrades | Servo speed and shelf-income multiplier, four levels each |
| World | Four per-server arcade plots, neon floor rails, cabinets, shelves, owner-bounded requests |
| UI | HUD, inventory/index, machine unlocks, upgrades, closed shop, keyboard and on-screen direction controls |
| Persistence | Studio-only memory backend; separate live DataStore adapter with session lease and serialized saves |
| Commerce | Cosmetic schema only; zero IDs, no checkout, unresolved receipts not acknowledged |

## Observed verification

- All seven final Luau scripts compiled in Roblox's actual runtime.
- **78 contract assertions** passed: scientific arithmetic, grants/display, income, replay-safe collect/sale, caps, earned machine unlock, profile validation, lease exclusion, load/save failures, rejoin recovery, stale-owner rejection and closed product catalog.
- Real desktop mouse input completed the first catch/display/collect/Classic unlock loop; a servo upgrade succeeded and a Classic catch produced Mochi Bunny.
- Keyboard D moved the authoritative aim marker; Space completed a catch. Simulated on-screen control interaction also moved the aim marker and completed a catch.
- Laptop, iPad Pro M5 and iPhone 17 Pro portrait/landscape layouts were inspected in the Studio simulator. Physical-device touch behavior and a full multi-client run remain open. Simulator path-based mouse clicks had an inset-related targeting inconsistency, so visual layout checks are not equivalent to exhaustive mobile input certification.
- No game-script exceptions were observed after fixing the initial blocking PlayerModule wait. Studio/CorePackages warnings and an avatar asset-type error remain in the host console; those are separate from the game scripts and no game code references that asset.
- Live Studio rollback removed only the new namespaces and restored the captured environment; the game was then reinstalled. Local rollback operates on a separate copy in its test mode and protects later edits.

Exact commands, literal results, hashes and file paths: [VERIFICATION.txt](file:///C:/Users/mason/OneDrive/Desktop/slopshitv1/claw-machine-empire/evidence/VERIFICATION.txt).

## Deliberate alpha differences from the full design

The brief's $25K Classic target is replaced with $250 for a short test loop. Six species and two tiers are playable, not hundreds of species or ten tiers. A Neon bay is clearly marked Build 02. Merging, ascension, additional floor space, quests, leaderboards, live offers and original audio are future work. Saves were fault-tested using an injected backend; live Roblox DataStore operations still need a published test universe. Scientific money has bounded exponents and finite significant precision, not mathematical infinity.

## Source and design references

- [[Original Game Design]] and [[Claw Machine Empire - Visual Direction]].
- [[REF - Client-server boundary validation]] — request ownership, type/value checks and rate limits.
- [[REF - Player data and purchasing systems]] — session ownership, failure handling and ordered saves.
- [MarketplaceService official API](https://create.roblox.com/docs/reference/engine/classes/MarketplaceService) — unresolved receipt behavior; no live purchase path is claimed.
- [[Systems Invariants and Schema Sketch]] · [[Durable idempotent purchase grants]].
