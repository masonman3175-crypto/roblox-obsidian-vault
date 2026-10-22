---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Asset acceptance is functional

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Test scale, collision, orientation, permissions, and cost for every authored asset family.

## Implementation and rationale
Use a reference avatar and a standard pickup/display rig. Check largest and smallest cosmetic variants as well as the base species. Inspect unloaded or unapproved asset behavior in a published test place. Prefer a simple collision proxy rather than letting decorative spikes alter game balance.

## Acceptance test
- [ ] A contact sheet and import report pass, then the asset completes grab, carry, deposit, display, and reload scenarios without clipping the camera or changing the route difficulty.

## Related decisions
- [[Generated mesh import checklist]]
- [[Collectibles that read at a distance]]
- [[Consistent inventory previews]]
- [[Asset provenance and ownership ledger]]

## Sources
- [[REF - Studio Importer]]
- [[REF - Custom 3D assets]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]
