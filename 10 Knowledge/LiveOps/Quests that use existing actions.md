---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Quests that use existing actions

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a small data-driven objective vocabulary that maps to authoritative gameplay events.

## Implementation and rationale
Draft objectives such as deposit snacks, discover a family, take a new route, or help another carrier. Specify quantity, reward, eligibility, and claim identity. Avoid daily chores requiring long waits, purchases, or an available friend. Keep an accessible solo alternative for cooperative tasks. Rewards should not silently overwhelm the main economy.

## Acceptance test
- [ ] Complete, reconnect, and claim twice. A quest progresses from actual successful actions, and a new player can finish a normal daily set without spending.

## Related decisions
- [[Collection as a goal system]]
- [[Currency sources and sinks ledger]]
- [[Free and premium season tracks]]
- [[Co-op goals with equitable credit]]

## Sources
- [[REF - Introduction to quest design]]
- [[REF - LiveOps essentials]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
