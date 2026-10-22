---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Fun at one concurrent player

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
The entire basic loop must work in an empty server.

## Implementation and rationale
Guardians, route hazards, and timed deliveries supply challenges when no other players join. Public events should scale or have a solo variant. Defer separate ranked queues until real concurrency supports them; a queue screen is not content. Never show fabricated activity to disguise an empty server.

## Acceptance test
- [ ] Join a fresh private test server alone and complete every required progression step. No quest should require another player until a solo alternative exists.

## Related decisions
- [[Guardian behavior that players can learn]]
- [[Social play that creates stories]]
- [[Concurrency-dependent features need a fallback]]
- [[Small launch before paid scale]]

## Sources
- [[REF - Prototyping]]
- [[REF - LiveOps essentials]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
