---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Measure the aftermath of failure

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A tense game needs to know whether failure produces another attempt or a departure.

## Implementation and rationale
Draft metrics for run start, outcome, cargo value band, next action, and time to retry. Compare new and experienced players without logging sensitive free text. Qualitative comments explain why a loss felt unfair; numbers alone do not. Use this evidence before adding paid rescue or more aggressive raiding.

## Acceptance test
- [ ] A test loss generates one outcome event and one later retry or observed exit state. Replaying a client event cannot fabricate economy or reward changes.

## Related decisions
- [[Risk without permanent misery]]
- [[Minimal event taxonomy]]
- [[Grief recovery and protected progress]]
- [[One question per experiment]]

## Sources
- [[REF - Custom events]]
- [[REF - Core loops]]

Map: [[MOC - Growth and Analytics]] · [[START HERE - Slop Game Lab]]
