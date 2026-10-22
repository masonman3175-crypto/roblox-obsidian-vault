---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Player feedback becomes a reproducible issue

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Separate bug reports, expectation mismatch, balance complaints, and feature requests.

## Implementation and rationale
Collect minimal relevant details and avoid requesting private personal information. Convert repeatable complaints into a test fixture and link them to the owning system. A vocal player is not automatically representative of the whole cohort, but recurring frustration deserves investigation. Close the loop with specific fixes rather than vague promises.

## Acceptance test
- [ ] Take one vague complaint about losing an item and trace it to a reproducible lifecycle or save case. The issue includes steps and evidence before an implementation task is opened.

## Related decisions
- [[Bug reports with reproducible evidence]]
- [[Measure the aftermath of failure]]
- [[Evidence labels prevent invented certainty]]
- [[Postmortem after every meaningful update]]

## Sources
- [[REF - Get started with analytics]]
- [[REF - Prototyping]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
