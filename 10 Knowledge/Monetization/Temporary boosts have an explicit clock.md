---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Temporary boosts have an explicit clock

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
State the duration, affected actions, stacking rule, and offline behavior before purchase.

## Implementation and rationale
Prefer an optional non-random convenience boost for the first release. Use an expiry timestamp or durable remaining-time design with a clear pause rule. Do not restart a paid duration on every reconnect or consume it during unresolved loading without explanation. A luck modifier changes probability and requires a different policy review.

## Acceptance test
- [ ] Buy with a test receipt, disconnect mid-duration, overlap two boosts, and rejoin after expiry. The displayed and actual durations follow the same documented rule.

## Related decisions
- [[Bounded multiplier stacking]]
- [[Durable idempotent purchase grants]]
- [[Paid randomness decision gate]]
- [[Runtime prices not painted prices]]

## Sources
- [[REF - Developer products]]
- [[REF - Paid random item guidelines]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
