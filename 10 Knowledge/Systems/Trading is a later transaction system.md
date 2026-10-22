---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Trading is a later transaction system

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Defer player trading until item identity, data ownership, policy rules, and recovery are understood.

## Implementation and rationale
A two-player trade needs explicit offers, acceptance invalidation on changes, a final review, durable transaction identity, and crash recovery. Two separate profile saves are not an atomic exchange. Preserve paid-item provenance and account restrictions. For MVP, use direct NPC selling rather than a fragile player marketplace.

## Acceptance test
- [ ] Change an offer after acceptance, disconnect either side during commit, and replay the transaction. Neither duplication nor permanent loss is acceptable before the feature ships.

## Related decisions
- [[Stable item IDs and provenance]]
- [[Session ownership and concurrent joins]]
- [[Paid randomness decision gate]]
- [[Runtime prices not painted prices]]

## Sources
- [[REF - PolicyService API]]
- [[REF - Player data and purchasing systems]]
- [[REF - Regional pricing]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
