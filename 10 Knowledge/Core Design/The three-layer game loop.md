---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# The three-layer game loop

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Define one repeatable action, one session objective, and one longer-term collection goal before adding a shop.

## Implementation and rationale
For Snatch a Snack, the action is grabbing and escaping with a snack-creature. A session ends with a new display or upgrade. Long-term progress is completing themed collections. Keep these three rewards distinct so players can explain why another run matters. Build only one arena until this is readable.

## Acceptance test
- [ ] Ask five fresh testers to describe their next action without coaching; record hesitation and abandoned runs, not just whether they liked the art.

## Related decisions
- [[A ten-second hook]]
- [[Greybox before content volume]]
- [[Progression adds decisions]]
- [[First successful run]]

## Sources
- [[REF - Core loops]]
- [[REF - Prototyping]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
