---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Persistence fault-injection matrix

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A save system needs adversarial failure tests before it handles valuable progress.

## Implementation and rationale
Cases include failed load, delayed load, failed autosave, shutdown, rapid rejoin, concurrent session, migration, and receipt fulfilment during a save failure. Use isolated test data and record the expected recovery for each case. Do not enable a live data store casually just to make a test pass.

## Acceptance test
- [ ] Run each case from a known fixture and compare the durable result with the expected record. Default data never overwrites a failed load and a valid purchased grant is never silently discarded.

## Related decisions
- [[Persistence is part of gameplay]]
- [[Session ownership and concurrent joins]]
- [[Durable idempotent purchase grants]]
- [[Versioned player-data migrations]]

## Sources
- [[REF - Data stores]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]
