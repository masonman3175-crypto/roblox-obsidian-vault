---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Cohort retention not a magic benchmark

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Measure whether real first-time players return and compare like-for-like cohorts.

## Implementation and rationale
Keep acquisition source, build version, major event exposure, and device mix in view. Do not compare a tiny friends-and-family group directly against paid traffic and conclude the game improved. D1 and later retention answer different questions from average session duration. Document the denominator and missing-data assumptions.

## Acceptance test
- [ ] For each experiment, retain cohort dates, player count, and the exact return definition. Mark incomplete observation windows instead of reporting immature D7 or D30 values as final.

## Related decisions
- [[One question per experiment]]
- [[Small launch before paid scale]]
- [[Minimal event taxonomy]]
- [[Postmortem after every meaningful update]]

## Sources
- [[REF - Retention]]
- [[REF - Analytics overview]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
