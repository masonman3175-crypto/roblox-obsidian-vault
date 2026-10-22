---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Currency sources and sinks ledger

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Name every way coins enter and leave the economy before running an event.

## Implementation and rationale
Draft sources: successful delivery, displays, quests. Draft sinks: upgrades, base decor, optional fusion. Record amounts and resulting balances through the authoritative currency path. Avoid counting a request as an economic transaction before it succeeds. Compare source/sink mixes across progression bands rather than only total coins in circulation.

## Acceptance test
- [ ] Run a deterministic test session and reconcile starting balance plus sources minus sinks against the final saved balance. Analytics failure must not reverse a successful gameplay operation.

## Related decisions
- [[One currency mutation path]]
- [[Inflation and content consumption]]
- [[Separate event currency deliberately]]
- [[Minimal event taxonomy]]

## Sources
- [[REF - Economy events]]
- [[REF - Balance virtual economies]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
