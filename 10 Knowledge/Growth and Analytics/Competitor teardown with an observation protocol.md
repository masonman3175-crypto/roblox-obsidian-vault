---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Competitor teardown with an observation protocol

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Study how games communicate decisions, not just their visible shop buttons.

## Implementation and rationale
Record access date, platform, exact first actions, UI hierarchy, loop timings, failure recovery, social interactions, and monetization placement. Mark unplayed games as reference-only. The attached screenshot supports static observations only; it does not prove spawn logic, economy rates, or retention. Keep original design changes in a separate column.

## Acceptance test
- [ ] Two researchers can distinguish observation from inference in the same teardown. Any claim about hidden mechanics has a direct gameplay or documentation basis.

## Related decisions
- [[Inspiration without a reskin]]
- [[Video research without success-story bias]]
- [[Evidence labels prevent invented certainty]]
- [[A ten-second hook]]

## Sources
- [[REF - Prototyping]]
- [[REF - Discovery metadata guidance]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
