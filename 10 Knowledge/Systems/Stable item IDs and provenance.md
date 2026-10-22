---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Stable item IDs and provenance

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Separate species definitions from individual inventory instances.

## Implementation and rationale
A species key refers to authored data; an instance ID refers to one owned snack. Store owner, acquisition type, creation time, and applicable trading flags independently of the rendered model. Do not use a model name or its position as the only identifier. Migrations should preserve identity where possible.

## Acceptance test
- [ ] Spawn two copies of the same species; they have distinct instance IDs. Rejoin and duplicate receipt tests preserve the intended count without merging unrelated items.

## Related decisions
- [[Inventory is not the Workspace]]
- [[Collection as a goal system]]
- [[Trading is a later transaction system]]
- [[Versioned player-data migrations]]

## Sources
- [[REF - Properties and attributes]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
