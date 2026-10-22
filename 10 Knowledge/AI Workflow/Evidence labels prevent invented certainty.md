---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Evidence labels prevent invented certainty

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Label each reference by what was actually inspected and each design statement by its evidence status.

## Implementation and rationale
Use page-read for content inspected, search-excerpt for search-supplied passages, page-opened when only the page identity was confirmed, transcript-reviewed for video text, and legacy-unverified for inherited recommendations. A compelling video is a case study, not proof of revenue or general model superiority. Store dates and exact URLs.

## Acceptance test
- [ ] Pick five claims and follow their citations. The source supports the narrow fact, while proposed prices, timings, and mechanics are clearly marked as project hypotheses.

## Related decisions
- [[The coding robot context packet]]
- [[Competitor teardown with an observation protocol]]
- [[One question per experiment]]
- [[Video research without success-story bias]]

## Sources
- [[REF - Coding-agent best practices]]
- [[REF - Analytics overview]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]
