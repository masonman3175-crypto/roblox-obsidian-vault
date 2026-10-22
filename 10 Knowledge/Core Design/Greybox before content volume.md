---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Greybox before content volume

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Test the route and escape decision using boxes before generating dozens of collectible variants.

## Implementation and rationale
Make a shared island, two return routes, one guardian, and two bases. Use bright blocks for danger and reward. Compare a short risky path with a longer reliable path. If both choices feel identical, change the geometry or guardian timing before spending more effort on models.

## Acceptance test
- [ ] Run the same scenario with one and two players. Record route choice, completion time, and whether the failed run invites another attempt.

## Related decisions
- [[The three-layer game loop]]
- [[Risk without permanent misery]]
- [[Guardian behavior that players can learn]]
- [[Measured mobile performance budget]]

## Sources
- [[REF - Prototyping]]
- [[REF - Studio testing modes]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
