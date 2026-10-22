---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Collectibles that read at a distance

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A collectible should be recognizable by outline before rarity particles or texture details appear.

## Implementation and rationale
Draft families with different primary masses: a squat soda slug, a tall noodle kite, a round dumpling comet, and a wide waffle crab. Limit tiny protrusions that vanish on mobile. Use one functional root and consistent preview orientation. Keep rarity upgrades from changing pickup hitboxes unpredictably.

## Acceptance test
- [ ] Render or inspect each asset as a single black shape at small size. Testers can tell species apart without relying on color, labels, or VFX.

## Related decisions
- [[Original art bible]]
- [[Rarity communicates through more than color]]
- [[Consistent inventory previews]]
- [[Asset acceptance is functional]]

## Sources
- [[REF - Custom 3D assets]]
- [[REF - Accessibility guidelines]]

Map: [[MOC - Art and Content]] · [[START HERE - Slop Game Lab]]
