---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Chunky buttons with honest states

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Every button needs idle, focus, pressed, disabled, and busy states that communicate what will happen.

## Implementation and rationale
Use a strong edge, readable icon, short verb, and gentle scale feedback. Disabled actions explain the missing requirement without opening a purchase prompt. Busy state prevents duplicate input while a server request is pending. Controller focus should be visible without hover. Keep the close button separate from paid confirmation.

## Acceptance test
- [ ] Navigate only with a controller, then repeat with touch. A double tap on a busy action does not send duplicate purchase or reward requests.

## Related decisions
- [[A reusable toy-box visual system]]
- [[Controller focus is a first-class state]]
- [[Purchase flow is a state machine]]
- [[Juice with an off switch]]

## Sources
- [[REF - UI appearance modifiers]]
- [[REF - Cross-platform development]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
