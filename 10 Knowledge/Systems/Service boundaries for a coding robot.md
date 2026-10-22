---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Service boundaries for a coding robot

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Assign each kind of valuable state one owner before asking AI to generate scripts.

## Implementation and rationale
Inventory owns item records; Currency owns balances; Collectibles owns world lifecycle; Bases owns display occupancy; Purchases orchestrates durable grants; UI only renders. Define service inputs, return values, and failure codes in notes first. Prevent each button script from inventing its own save or purchase path.

## Acceptance test
- [ ] Trace one deposit from request to saved record. There is one owner for the item and no circular service dependency on the happy path.

## Related decisions
- [[Intent-only network contracts]]
- [[Collectible lifecycle state machine]]
- [[Persistence is part of gameplay]]
- [[The coding robot context packet]]

## Sources
- [[REF - Remote events and callbacks]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
