---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Bases as collectible showcases

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
The base should celebrate ownership while remaining visually and computationally bounded.

## Implementation and rationale
Use a fixed display-slot grid with clear occupied and available states. Standardize maximum preview scale so a giant cosmetic cannot cover neighbors. Add purchasable pedestal themes without changing income. A display is a projection of inventory identity and must recover if its model is deleted or streamed out.

## Acceptance test
- [ ] Reload the base with all slots occupied, remove one rendered model, and rejoin. The server record reconstructs the right displays without minting items or losing ownership.

## Related decisions
- [[Capacity is a pacing tool not a trap]]
- [[Inventory is not the Workspace]]
- [[Rarity VFX within a budget]]
- [[Cosmetics can carry catalog breadth]]

## Sources
- [[REF - Custom 3D assets]]
- [[REF - Design for performance]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
