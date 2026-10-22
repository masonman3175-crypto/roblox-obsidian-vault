---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Asset provenance and ownership ledger

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Track where each asset came from and who can use it.

## Implementation and rationale
For each model, icon, texture, animation, and audio file, record local source, creator, license or permission basis, generation tool if any, Roblox asset ID, experience/group usage permissions, and approval state. Keep third-party references as references, not as a production asset library. Do not accept unknown scripts embedded in a free model without inspection.

## Acceptance test
- [ ] Choose any production asset and trace its editable source and usage permissions. A new group test experience can load approved assets without falling back to another person's private asset.

## Related decisions
- [[Generated mesh import checklist]]
- [[Audio imports and mix controls]]
- [[Inspiration without a reskin]]
- [[Release packet and rollback boundaries]]

## Sources
- [[REF - Studio Importer]]
- [[REF - Audio assets]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
