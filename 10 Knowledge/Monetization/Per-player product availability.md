---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Per-player product availability

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Availability should be determined before exposing or executing a restricted product flow.

## Implementation and rationale
Fetch policy information through a server-owned adapter, cache only with an intentional lifecycle, and handle failure conservatively for the affected feature. UI absence is not enough; server purchase entry and reward resolution need the same rule. Keep ordinary direct cosmetics and basic gameplay independent of the restricted feature.

## Acceptance test
- [ ] Use eligible, restricted, and failed-policy test fixtures. Restricted paths remain blocked server-side while the rest of the game still works and provides a useful alternative.

## Related decisions
- [[Paid randomness decision gate]]
- [[Intent-only network contracts]]
- [[Shop browsing before checkout]]
- [[Product eligibility test fixtures]]

## Sources
- [[REF - PolicyService API]]
- [[REF - Paid random item guidelines]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
