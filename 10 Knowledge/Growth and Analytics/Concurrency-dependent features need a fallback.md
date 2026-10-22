---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Concurrency-dependent features need a fallback

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Do not let a thin queue become the main experience for a small new game.

## Implementation and rationale
For a future competitive mode, state a minimum viable population and a timeout path to solo practice or normal play. Keep progression valid outside ranked mode. Avoid splitting the audience into many unnecessary places or queues before data supports it. Provide clear status without inventing opponents or wait estimates.

## Acceptance test
- [ ] Test zero, one, two, and several queued players. Everyone can return to meaningful play and no required quest depends on an unfilled queue.

## Related decisions
- [[Fun at one concurrent player]]
- [[Social play that creates stories]]
- [[Small launch before paid scale]]
- [[Minimal event taxonomy]]

## Sources
- [[REF - Prototyping]]
- [[REF - Analytics overview]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
