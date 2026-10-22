---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Upgrade curves with readable payback

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Balance upgrade cost against added earning rate, not just a satisfying-looking exponential formula.

## Implementation and rationale
For draft balancing, calculate paybackSeconds as cost divided by added income per second. Use a table of early, middle, and late checkpoints and simulate an unpaid player through them. The target timings are project hypotheses. Avoid an extreme late bottleneck designed only to sell a bypass.

## Acceptance test
- [ ] For every upgrade, inspect cost, added income, and payback at that moment. A new player never needs a paid multiplier to reach the next meaningful action.

## Related decisions
- [[Progression adds decisions]]
- [[One currency mutation path]]
- [[Deterministic economy simulation]]
- [[Bounded multiplier stacking]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Core loops]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
