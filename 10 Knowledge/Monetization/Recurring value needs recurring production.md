---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Recurring value needs recurring production

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Add a subscription only after the team can deliver a repeatable stream of distinct benefits.

## Implementation and rationale
A draft club could offer a monthly cosmetic choice and a rotating base decoration library. Explain the renewal period and what remains after access ends. Do not grant an infinite competitive advantage that the economy requires. Use the platform's current subscription APIs and eligibility rules; a recurring product is not just a timed game pass.

## Acceptance test
- [ ] Test active, expired, cancelled-but-still-entitled, and renewed states according to the actual platform lifecycle. The shop and server agree on which benefits remain.

## Related decisions
- [[Products are not all the same entitlement]]
- [[Data-driven content production]]
- [[A sustainable release calendar]]
- [[Cosmetics can carry catalog breadth]]

## Sources
- [[REF - Subscriptions]]
- [[REF - Subscription design]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
