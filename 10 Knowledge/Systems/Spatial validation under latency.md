---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Spatial validation under latency

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Validate important interactions against server-observed world state, with tolerance chosen for the actual movement rules.

## Implementation and rationale
Distance checks alone may be insufficient when a client owns moving physics objects. Anchor critical pickup anchors or manage ownership deliberately, and require plausible route and state transitions. Distinguish normal lag from impossible requests. Do not automatically punish a player for one noisy sample.

## Acceptance test
- [ ] Run high-latency tests and a malformed-request harness. Legitimate delayed deposits still complete while remote collection across the arena is rejected.

## Related decisions
- [[Intent-only network contracts]]
- [[Carrying creates a readable choice]]
- [[Two-client and bad-network scenarios]]
- [[Rate limits are gameplay contracts]]

## Sources
- [[REF - Network ownership and movement]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
