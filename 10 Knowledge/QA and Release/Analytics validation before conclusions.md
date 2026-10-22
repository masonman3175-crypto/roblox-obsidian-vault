---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Analytics validation before conclusions

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
First prove the events represent reality, then interpret dashboards.

## Implementation and rationale
Use a stub sink in local tests to assert names, step order, and duplicate suppression. Use a published test experience to verify actual delivery through the platform's event inspection tools. Note that dashboards may lag. A missing chart in Studio is not evidence that production tracking is broken or working.

## Acceptance test
- [ ] Compare a known session trace with expected counts and server-authoritative outcomes. Failed purchases never appear as successful currency grants and repeated claims do not inflate discovery totals.

## Related decisions
- [[Minimal event taxonomy]]
- [[A measurable onboarding funnel]]
- [[Currency sources and sinks ledger]]
- [[Shop metrics include failed fulfilment]]

## Sources
- [[REF - Analytics event types]]
- [[REF - Funnel events]]
- [[REF - Custom events]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]
