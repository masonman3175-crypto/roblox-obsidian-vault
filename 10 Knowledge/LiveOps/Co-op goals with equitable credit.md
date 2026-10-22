---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Co-op goals with equitable credit

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make contribution visible and reward useful participation, not only the last touch.

## Implementation and rationale
Draft a public delivery crate with a bounded shared goal. Track each participant's verified contribution, provide individual rewards once, and allow solo completion at a slower but reasonable pace. Avoid rewards based purely on chat or client-reported damage. Keep event participation optional and clearly signposted.

## Acceptance test
- [ ] A late joiner, a low-level player, and a disconnected participant receive outcomes that match the documented contribution rules. Rejoining never creates a second reward.

## Related decisions
- [[Social play that creates stories]]
- [[Quests that use existing actions]]
- [[Fun at one concurrent player]]
- [[One event template with many themes]]

## Sources
- [[REF - Introduction to quest design]]
- [[REF - Remote events and callbacks]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
