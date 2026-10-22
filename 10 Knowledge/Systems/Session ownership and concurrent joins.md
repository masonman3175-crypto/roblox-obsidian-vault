---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Session ownership and concurrent joins

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Prevent two servers from independently saving different versions of the same player record.

## Implementation and rationale
Choose a reviewed session-ownership design or maintained implementation and understand its lease and release semantics. Do not assume UpdateAsync alone solves every in-memory concurrency problem. A crashed server's ownership must eventually become recoverable without accepting two active writers. Keep data-layer responsibilities outside UI scripts.

## Acceptance test
- [ ] Rapidly move a test account between servers while a purchase is processed. Verify only one writable session and a documented recovery after an abrupt server loss.

## Related decisions
- [[Persistence is part of gameplay]]
- [[Durable idempotent purchase grants]]
- [[Versioned player-data migrations]]
- [[Trading is a later transaction system]]

## Sources
- [[REF - Player data and purchasing systems]]
- [[REF - Data stores]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
