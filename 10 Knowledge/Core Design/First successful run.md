---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# First successful run

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Teach movement, grab, return, display, and upgrade through actions, not a stack of onboarding windows.

## Implementation and rationale
Use one active instruction at a time. Give the player a guaranteed first snack and a clearly marked display. Save completed tutorial steps so reconnecting does not restart everything. Reveal the index after the first successful deposit; the tutorial should teach value before presenting optional purchases.

## Acceptance test
- [ ] A new touch player completes a full loop without being asked to buy anything. Rejoin between each tutorial step and verify progression resumes coherently.

## Related decisions
- [[A ten-second hook]]
- [[Contextual guidance that ends]]
- [[A measurable onboarding funnel]]
- [[Persistence is part of gameplay]]

## Sources
- [[REF - Onboarding]]
- [[REF - Funnel events]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
