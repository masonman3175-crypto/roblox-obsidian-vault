---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Index cards that guide exploration

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make the collection menu an actionable map of missing discoveries.

## Implementation and rationale
Cards show original icon or 3D preview, family, rarity label, first-discovery state, and a broad location hint. Filters distinguish owned, missing, and cosmetic variants. Give a separate claim button only when a milestone is ready. Do not hide essential access requirements behind a mystery icon.

## Acceptance test
- [ ] A new player chooses a specific next target without outside instructions. Text and icon remain useful when the preview asset fails to load.

## Related decisions
- [[Collection as a goal system]]
- [[Rarity communicates through more than color]]
- [[Useful loading and error states]]
- [[Localization-ready strings from day one]]

## Sources
- [[REF - User interface overview]]
- [[REF - Introduction to quest design]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
