---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Deterministic economy simulation

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep a small model of the economy outside the game for quick consistency checks.

## Implementation and rationale
Use fixed inputs for earned coins, upgrade costs, boost durations, and event awards. Generate checkpoints for an unpaid path and optional-purchase scenarios. This is a model, not proof of retention or revenue. Change one parameter at a time and record why. Test arithmetic independently of rendering and network code.

## Acceptance test
- [ ] Assert nonnegative balances, monotonic costs where intended, a finite progression path, correct boost expiry, and bounded offline rewards. Store seeds if any simulated outcomes are randomized.

## Related decisions
- [[Upgrade curves with readable payback]]
- [[Bounded multiplier stacking]]
- [[Offline income needs bounds and provenance]]
- [[Inflation and content consumption]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Prototyping]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
