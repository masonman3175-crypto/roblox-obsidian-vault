---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Asset prompts need an art contract

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Request an original object with clear functional constraints and a consistent family style.

## Implementation and rationale
For a model, specify proportions, editable parts, collision proxy, scale, pivot, and budget. For an icon, specify canvas, silhouette, visual family, and transparent background where needed. Keep text labels in UI rather than asking generated art to spell every price. The model-generation prompt and image-composition prompt have different purposes.

## Acceptance test
- [ ] Inspect output against a checklist, not merely visual appeal. A beautiful image is not counted as an imported mesh or a functioning shop button.

## Related decisions
- [[Original art bible]]
- [[Generated mesh import checklist]]
- [[Consistent inventory previews]]
- [[Asset provenance and ownership ledger]]

## Sources
- [[REF - Assistant prompt guide]]
- [[REF - Assistant for Studio]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]
