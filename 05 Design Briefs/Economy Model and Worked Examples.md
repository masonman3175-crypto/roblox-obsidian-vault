---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, brief, economy]
---

# Economy Model and Worked Examples

## Status
Illustrative arithmetic and a proposed balancing model. These values are not extracted from Steal an Egg and do not predict revenue or retention. A small companion Python model is tested outside the vault; no game code has been run by those model tests.

## Draft values
- Base display production: 2 coins/second.
- First upgrade: 60 coins; adds 1 coin/second.
- Second upgrade: 180 coins; adds 2 coins/second.
- A sample collection outcome table: weights 60, 30, 10 and earned values 10, 20, 50.
- Offline claim cap: two hours in the example model; a design hypothesis, not a platform limit.

## Worked calculations
First-upgrade payback is `60 / 1 = 60 seconds` after purchasing. Second-upgrade payback is `180 / 2 = 90 seconds` after purchasing. This is the recovery of the spent cost from **incremental** production, not total time to earn the upgrade and not a required session length.

The example outcome expected value is `0.60*10 + 0.30*20 + 0.10*50 = 17 coins`. If an event multiplies all awards by 1.5 while attempts stay constant, the expected per-attempt reward becomes 25.5. Participation changes can alter total supply further; multiplying a reward table alone does not model the entire event.

Offline draft calculation: `earned = rate * clamp(serverNow - lastSavedTime, 0, capSeconds)`. At 2 coins/second and a two-hour cap, the maximum example claim is 14,400 coins. Evaluate whether that trivializes the next upgrades before enabling it. A future timestamp must not produce negative earnings.

## Sources and sinks
Start balance plus successful deliveries plus display earnings plus quests plus explicit purchases minus upgrades minus chosen decor minus deterministic recipes equals ending balance. Track event tokens separately. Give every mutation a reason and validate the amounts before applying it.

## Model boundaries
The deterministic test model checks arithmetic invariants, not Roblox networking, DataStores, ProcessReceipt, player motivation, or live platform eligibility. A model passing does not imply the game is built. Review all economic values with unpaid testers and real server telemetry after a working slice exists.

## Next tests
Compare no-purchase, one cosmetic, and optional boost paths; all should preserve meaningful route decisions. Add a table of time-to-goal across progression bands and inspect both typical and high-yield cases. Re-run after any multiplier, offline rule, or event change.

Related: [[Deterministic economy simulation]] · [[Upgrade curves with readable payback]] · [[Offline income needs bounds and provenance]] · [[Inflation and content consumption]] · [[Currency sources and sinks ledger]]

Source background: [[REF - Balance virtual economies]] · [[REF - Economy events]]
