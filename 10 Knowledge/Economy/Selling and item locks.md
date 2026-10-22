---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Selling and item locks

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Allow an uncomplicated way to clear unwanted items without turning the shop into a destructive-action minefield.

## Implementation and rationale
Show the selected item and exact coin return. Favorite items require explicit unlocking; equipped or displayed items require a valid transition. Use instance IDs and one server operation for removal plus credit. Do not show an attractive paid card in the same position as a sell confirmation.

## Acceptance test
- [ ] Send sell twice for one instance and try selling a currently reserved fusion ingredient. Only one valid sale occurs, and the UI explains rejected states.

## Related decisions
- [[Destructive actions need a preview]]
- [[Stable item IDs and provenance]]
- [[Fusion as a deterministic MVP]]
- [[One currency mutation path]]

## Sources
- [[REF - Client-server boundary validation]]
- [[REF - Balance virtual economies]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
