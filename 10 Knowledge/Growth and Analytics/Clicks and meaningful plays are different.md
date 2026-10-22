---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Clicks and meaningful plays are different

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Evaluate acquisition through the complete path from impression to an engaged session.

## Implementation and rationale
Track the platform's currently defined acquisition metrics alongside onboarding completion, session quality, and return cohorts. A high click rate with immediate exits can signal misleading creative, poor loading, or a weak loop. Do not optimize the picture in isolation or treat any single metric as a guaranteed discovery hack.

## Acceptance test
- [ ] Compare two truthful creatives on both entry and downstream play, with cohort sizes and dates recorded. A small noisy difference is not declared a permanent winner.

## Related decisions
- [[Thumbnail promise matches the first minute]]
- [[A measurable onboarding funnel]]
- [[Minimal event taxonomy]]
- [[Small launch before paid scale]]

## Sources
- [[REF - Acquisition]]
- [[REF - Thumbnails]]
- [[REF - Discovery]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
