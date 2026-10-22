---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Deposits must commit once

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A successful return converts one carried object into one inventory or display record through a single transaction boundary.

## Implementation and rationale
Check carrier identity, current lifecycle state, destination ownership, free slot, and current position. Reserve the slot, update authoritative records together, then publish the new view. If persistence is delayed, do not allow repeated trigger events to mint additional rewards. Distinguish transient unsaved progress from acknowledged purchases.

## Acceptance test
- [ ] Enter the deposit area twice, reset during deposit, and let two actions target the last slot. The resulting records satisfy one-item and one-slot invariants.

## Related decisions
- [[Carrying creates a readable choice]]
- [[Collectible lifecycle state machine]]
- [[One currency mutation path]]
- [[Inventory is not the Workspace]]

## Sources
- [[REF - Client-server boundary validation]]
- [[REF - Data stores]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
