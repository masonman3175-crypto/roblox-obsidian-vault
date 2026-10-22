---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Data-driven content production

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Adding a species should mostly require a catalog row, approved asset, and tests, not new server logic.

## Implementation and rationale
Define family, rarity, biome, base production, collision proxy, preview, sound set, and optional cosmetic variants in a reviewed schema. Build a validation report before content is published. Keep the content cadence inside the team's actual capacity; visual variety is useful only when the loop supports it.

## Acceptance test
- [ ] Add a new species through the documented pipeline. Existing behavior works without new service code, and validation catches missing assets and invalid economic values.

## Related decisions
- [[Catalog and content validation]]
- [[Asset provenance and ownership ledger]]
- [[A sustainable release calendar]]
- [[Many products through one catalog]]

## Sources
- [[REF - Content updates]]
- [[REF - Properties and attributes]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
