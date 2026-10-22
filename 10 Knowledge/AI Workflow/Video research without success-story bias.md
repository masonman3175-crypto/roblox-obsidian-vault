---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Video research without success-story bias

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Record review mode, timestamps, observations, limits, and a concrete next experiment.

## Implementation and rationale
Three transcript reviews are included in the Video Review Desk. One shows iterative AI development, one a one-shot comparison, and one a polished project with weak early retention. Keep creator-reported numbers as anecdotes and avoid copying sponsored tool claims into the build stack. Playback and visual inspection are separate from transcript review.

## Acceptance test
- [ ] Each video note has real timestamp links and says what was and was not reviewed. The resulting task can be tested without assuming the video's income or model claims are true.

## Related decisions
- [[Evidence labels prevent invented certainty]]
- [[Competitor teardown with an observation protocol]]
- [[Small launch before paid scale]]
- [[One question per experiment]]

## Sources
- [[REF - Analytics overview]]
- [[REF - Prototyping]]

Map: [[MOC - AI Workflow]] · [[START HERE - Slop Game Lab]]
