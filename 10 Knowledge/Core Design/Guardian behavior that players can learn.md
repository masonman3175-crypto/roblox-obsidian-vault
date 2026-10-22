---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Guardian behavior that players can learn

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a small readable state machine instead of an always-perfect chaser.

## Implementation and rationale
A guardian patrols, notices an attempted grab, telegraphs pursuit, chases within a leash, and returns to its post. Each state has a distinct silhouette or animation. A route failure must reset the guardian to a valid state; it must not permanently camp the player's base. Budget path recomputation instead of computing on every frame.

## Acceptance test
- [ ] Block a route, remove a target, and reset the carrier. The guardian should recover, not become stuck or teleport unpredictably.

## Related decisions
- [[Bounded pathfinding and recovery]]
- [[Collectible lifecycle state machine]]
- [[Fun at one concurrent player]]
- [[A small consistent sound language]]

## Sources
- [[REF - Pathfinding]]
- [[REF - Core loops]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
