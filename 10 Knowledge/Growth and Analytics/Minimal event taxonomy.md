---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Minimal event taxonomy

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a small stable set of event names with bounded dimensions and clearly assigned owners.

## Implementation and rationale
Draft events: RunStarted, RunResolved, ItemDiscovered, UpgradePurchased, OfferViewed, GrantCompleted, FeatureUsed. Dimensions might include zone, input class, or configuration cohort, but do not stuff user text or unique receipt IDs into analytics labels. Keep operational logs and product analytics separate. Analytics failure cannot block the game loop.

## Acceptance test
- [ ] Replay one scripted session and compare expected event counts with captured calls. Check that currency events log committed outcomes and that dimensions do not grow without bound.

## Related decisions
- [[Currency sources and sinks ledger]]
- [[A measurable onboarding funnel]]
- [[Measure the aftermath of failure]]
- [[Analytics validation before conclusions]]

## Sources
- [[REF - Custom events]]
- [[REF - Analytics custom fields]]
- [[REF - Analytics event types]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
