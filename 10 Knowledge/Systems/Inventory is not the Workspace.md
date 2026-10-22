---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Inventory is not the Workspace

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use serializable inventory records as the source of truth and treat world models as projections.

## Implementation and rationale
A player can own an item even when its display model is not loaded. Store only stable keys and bounded fields, not Instance references. Add an explicit capacity result so a full inventory cannot silently destroy rewards. Queue pending grants when a durable entitlement exceeds current display capacity.

## Acceptance test
- [ ] Fill all slots, grant a legitimate reward, then rejoin. The item remains recoverable and cannot be claimed repeatedly from a pending queue.

## Related decisions
- [[Stable item IDs and provenance]]
- [[Persistence is part of gameplay]]
- [[Capacity is a pacing tool not a trap]]
- [[Index cards that guide exploration]]

## Sources
- [[REF - Data stores]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
