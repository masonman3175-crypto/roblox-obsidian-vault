---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Bounded pathfinding and recovery

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Path computation is an interruptible resource with failure states, not an automatic guarantee that a guardian reaches its target.

## Implementation and rationale
Compute paths at bounded intervals or after meaningful changes. Handle a blocked waypoint, missing target, failed computation, and pursuit timeout. Cancel listeners when the guardian despawns. Give a recovery behavior such as returning to its authored post rather than teleporting through a player. Keep the gameplay state separate from locomotion animation.

## Acceptance test
- [ ] Remove a bridge mid-chase, move the target outside the leash, and despawn the guardian while a computation is pending. The system recovers and does not accumulate listeners or tasks.

## Related decisions
- [[Guardian behavior that players can learn]]
- [[Collectible lifecycle state machine]]
- [[Lifecycle cleanup for long sessions]]
- [[Two-client and bad-network scenarios]]

## Sources
- [[REF - Pathfinding]]
- [[REF - Improve performance]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
