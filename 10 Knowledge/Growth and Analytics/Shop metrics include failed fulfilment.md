---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Shop metrics include failed fulfilment

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Revenue success includes users receiving what they purchased and understanding what it does.

## Implementation and rationale
Track voluntary shop entry, details views, purchase prompt attempts, cancellations where observable, confirmed grants, grant latency, and errors. Avoid inventing a reliable event for a platform state that is not exposed. Reconcile actual product sales and authoritative grants rather than assuming a UI click equals revenue.

## Acceptance test
- [ ] A failed test receipt increases a diagnostic count but never a successful-grant count. A replayed receipt does not inflate the number of fulfilled unique purchases.

## Related decisions
- [[Durable idempotent purchase grants]]
- [[Purchase flow is a state machine]]
- [[Minimal event taxonomy]]
- [[Offer placement without modal spam]]

## Sources
- [[REF - Monetization analytics]]
- [[REF - Developer products]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
