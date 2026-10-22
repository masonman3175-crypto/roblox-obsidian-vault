---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Reference packets instead of asset copying

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Build a small annotated packet for each feature, with reasons for including every image or link.

## Implementation and rationale
For a shop packet, include a hierarchy sketch, the original style guide, one relevant Roblox API page, product schema, and expected states. Mark what to borrow conceptually and what to create anew. Keep research source notes separate from actionable specifications so the robot does not interpret every tutorial recommendation as a requirement.

## Acceptance test
- [ ] Ask the robot to restate borrowed principles and new design decisions before implementation. Its task remains bounded even when the packet contains third-party promotional text.

## Related decisions
- [[The coding robot context packet]]
- [[Specify UI behavior as well as appearance]]
- [[Evidence labels prevent invented certainty]]
- [[Inspiration without a reskin]]

## Sources
- [[REF - Assistant prompt guide]]
- [[REF - Coding-agent best practices]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]
