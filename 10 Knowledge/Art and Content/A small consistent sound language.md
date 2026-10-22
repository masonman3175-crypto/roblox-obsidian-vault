---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# A small consistent sound language

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Assign a unique short cue to grab, danger, deposit, discovery, failure, and purchase fulfilment.

## Implementation and rationale
Keep action sounds distinct from ambient loops and music. Bound simultaneous voices and provide independent volume controls. Pair necessary information with visible feedback. Use licensed or original audio and verify experience permissions after upload. Avoid cloning an identifiable performer or franchise voice as a shortcut to an announcer.

## Acceptance test
- [ ] Mute the game and complete the loop, then play with UI hidden in a test capture. Neither mode is the only way to understand critical state changes.

## Related decisions
- [[Audio imports and mix controls]]
- [[Juice with an off switch]]
- [[Guardian behavior that players can learn]]
- [[Accessible feedback and localization audit]]

## Sources
- [[REF - Audio overview]]
- [[REF - Audio assets]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
