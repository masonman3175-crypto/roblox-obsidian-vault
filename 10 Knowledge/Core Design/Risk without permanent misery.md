---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Risk without permanent misery

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep the tense moment in the current run rather than allowing stronger players to erase days of another player's collection.

## Implementation and rationale
Prototype contested unbanked cargo while deposited collectibles remain safe. Losing a run drops temporary cargo and leaves a visible retry route. If base raiding is later introduced, use clearly explained opt-in stakes and a bounded recoverable loss. Do not sell immunity from a frustration deliberately added to force purchases.

## Acceptance test
- [ ] After a failed run, testers can explain what was lost and what remained. Compare exit rates after loss and after success before adding more hazards.

## Related decisions
- [[Carrying creates a readable choice]]
- [[Grief recovery and protected progress]]
- [[Measure the aftermath of failure]]
- [[Starter bundle after demonstrated value]]

## Sources
- [[REF - Core loops]]
- [[REF - Contextual purchases]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
