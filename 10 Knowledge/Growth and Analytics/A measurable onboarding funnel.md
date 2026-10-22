---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# A measurable onboarding funnel

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Define tutorial steps around completed actions, not around opening an instructional popup.

## Implementation and rationale
Draft sequence: data ready, movement understood, snack grabbed, first deposit, display active, first free upgrade, next objective chosen. Log each step consistently once with stable names. Keep test fixtures for reconnecting between steps. Distinguish data-load exits from players who reached the world and chose to leave.

## Acceptance test
- [ ] In a published test experience, verify the expected sequence in the live event inspection view. Studio tests check wrapper calls but are not represented as delivered production analytics.

## Related decisions
- [[First successful run]]
- [[Analytics validation before conclusions]]
- [[Minimal event taxonomy]]
- [[Contextual guidance that ends]]

## Sources
- [[REF - Funnel events]]
- [[REF - Analytics event types]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
