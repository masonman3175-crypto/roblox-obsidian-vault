---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# One question per experiment

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Predefine the decision, primary metric, guardrails, duration, and interpretation before changing the game.

## Implementation and rationale
Example: test whether a clearer return marker improves first-deposit completion without slowing experienced players. Assign a stable cohort and avoid simultaneously changing pricing, map layout, and onboarding. Keep sample size and confidence visible. Small samples can guide qualitative exploration but should not become claims of statistical certainty.

## Acceptance test
- [ ] Write a prediction before launch and compare it with measured results. Record inconclusive outcomes honestly and avoid repeatedly stopping when a lucky result appears.

## Related decisions
- [[Cohort retention not a magic benchmark]]
- [[Clicks and meaningful plays are different]]
- [[Roll out economy changes with a return path]]
- [[Evidence labels prevent invented certainty]]

## Sources
- [[REF - Analytics overview]]
- [[REF - Prototyping]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
