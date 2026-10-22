---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Consistent inventory previews

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make preview generation a repeatable pipeline so the index never shows random backward models.

## Implementation and rationale
Define a standard camera angle, scale normalization, pivot, lighting, and background per asset family. Use image or 3D preview fallbacks deliberately. Store the generated preview identifier in the catalog rather than reconstructing it differently in each panel. Rebuild previews when silhouette or pivot changes.

## Acceptance test
- [ ] Compare all species in a contact sheet and in the smallest shop card. No model clips outside its bounds or faces backward, and failed assets still show readable names.

## Related decisions
- [[Index cards that guide exploration]]
- [[Collectibles that read at a distance]]
- [[Generated mesh import checklist]]
- [[Thumbnail promise matches the first minute]]

## Sources
- [[REF - User interface overview]]
- [[REF - Studio Importer]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
