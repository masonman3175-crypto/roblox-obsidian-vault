---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Collection as a goal system

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make the index answer what exists, what is owned, and where the next interesting target can be found.

## Implementation and rationale
Use silhouettes for undiscovered snacks, clear family names, and a discoverable zone hint. Keep cosmetic variants visually separate from functional species. Award collection milestones for first-time discoveries rather than endlessly buying the same item. A collection page should suggest the next run, not only display a completion percentage.

## Acceptance test
- [ ] A tester finds a missing family using the index. Duplicate acquisitions never count as multiple first discoveries and the claim action cannot grant twice.

## Related decisions
- [[Index cards that guide exploration]]
- [[Duplicates should have a clear purpose]]
- [[Stable item IDs and provenance]]
- [[Achievements recognize mastery]]

## Sources
- [[REF - Introduction to quest design]]
- [[REF - User interface overview]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
