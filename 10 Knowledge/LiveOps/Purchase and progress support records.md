---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Purchase and progress support records

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Design supportability into valuable transactions before real products are offered.

## Implementation and rationale
Keep bounded operational records for receipt identity, product ID, grant result, save result, and build version. Do not put full private records in public logs or analytics dimensions. Establish how the team will reconcile a delayed grant with platform records. Never ask the player to buy again as the first repair step.

## Acceptance test
- [ ] Use a test delayed receipt and produce a clear internal trace showing whether the purchase is pending, granted durably, or already acknowledged. The trace reveals no unnecessary personal data.

## Related decisions
- [[Durable idempotent purchase grants]]
- [[Shop metrics include failed fulfilment]]
- [[Persistence is part of gameplay]]
- [[Launch gate before live purchases]]

## Sources
- [[REF - Player data and purchasing systems]]
- [[REF - Developer products]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
