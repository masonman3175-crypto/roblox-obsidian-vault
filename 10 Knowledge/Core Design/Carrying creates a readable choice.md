---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Carrying creates a readable choice

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Make carrying an exposed, interruptible state with a deliberate risk reward trade-off.

## Implementation and rationale
The carried snack appears above or in front of the avatar with a consistent scale ceiling. The player chooses a slower safe return or a fast risky crossing. Do not base ownership on a welded model alone; the visual represents a server record. A successful deposit ends the carrying state exactly once.

## Acceptance test
- [ ] Two players try to grab the same snack; only one becomes carrier. Death, reset, falling, and leaving all have an explicit recovery path.

## Related decisions
- [[Collectible lifecycle state machine]]
- [[Stable item IDs and provenance]]
- [[Deposits must commit once]]
- [[Risk without permanent misery]]

## Sources
- [[REF - Remote events and callbacks]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
