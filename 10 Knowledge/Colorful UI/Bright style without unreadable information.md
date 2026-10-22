---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Bright style without unreadable information

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Keep saturated surfaces and readable information on separate layers.

## Implementation and rationale
Use a dark outline or calm panel behind white text, then verify contrast at the actual display size. Do not place tiny yellow prices on white gradients. Give audio cues a matching visual state and label hazards with a shape or symbol. Keep a larger-text setting and inspect text expansion during localization.

## Acceptance test
- [ ] Review a blurred screenshot and a grayscale capture. Important costs, current objective, close controls, and carried-item state remain understandable.

## Related decisions
- [[A reusable toy-box visual system]]
- [[Rarity communicates through more than color]]
- [[Localization-ready strings from day one]]
- [[Juice with an off switch]]

## Sources
- [[REF - Accessibility guidelines]]
- [[REF - UI and UX design]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
