---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Intent-only network contracts

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Clients request an action with a stable identifier; servers determine whether it is allowed and what it earns.

## Implementation and rationale
Prefer a request such as GrabSnack with itemId and a bounded requestId, not a client-selected reward or inventory table. Validate primitive types, string lengths, object existence, character state, distance, cooldown, and allowed transitions. Reply with a stable reason code so the client can recover cleanly.

## Acceptance test
- [ ] Send malformed, stale, out-of-range, and repeated requests through a development harness. None should change valuable state, and failures should be bounded and observable.

## Related decisions
- [[Service boundaries for a coding robot]]
- [[Rate limits are gameplay contracts]]
- [[Spatial validation under latency]]
- [[Collectible lifecycle state machine]]

## Sources
- [[REF - Remote events and callbacks]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
