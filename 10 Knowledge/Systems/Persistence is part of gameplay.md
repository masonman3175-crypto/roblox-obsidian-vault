---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Persistence is part of gameplay

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Treat load and save failures as designed states rather than exceptional afterthoughts.

## Implementation and rationale
Use a bounded schema with a version and durable receipt history. A failed load must not become an empty account that overwrites existing progress. Expose retry or read-only recovery instead. Test in a separate published environment and data namespace. Document autosave, leave, and shutdown behavior together.

## Acceptance test
- [ ] Simulate load failure, save failure, reconnect, and shutdown. No test writes default data over a failed load, and acknowledged purchases survive rejoining.

## Related decisions
- [[Session ownership and concurrent joins]]
- [[Durable idempotent purchase grants]]
- [[Versioned player-data migrations]]
- [[Persistence fault-injection matrix]]

## Sources
- [[REF - Data stores]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
