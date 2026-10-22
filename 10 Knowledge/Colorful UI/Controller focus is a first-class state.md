---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Controller focus is a first-class state

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Every actionable menu must be usable without a mouse cursor.

## Implementation and rationale
Define a predictable focus order, initial focus, visible selection, back action, and return focus after closing a modal. Do not strand selection on an offscreen item in a scrolling grid. Update input hints when the primary input changes. Keep analog navigation separate from gameplay movement while a modal is active.

## Acceptance test
- [ ] Open shop from gameplay, browse all tabs, inspect an item, cancel purchase, and return to play using only a controller. Switching to touch does not leave a focus trap.

## Related decisions
- [[Chunky buttons with honest states]]
- [[Mobile thumb zones and safe areas]]
- [[One modal at a time]]
- [[UI state and viewport matrix]]

## Sources
- [[REF - Cross-platform development]]
- [[REF - Studio testing modes]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
