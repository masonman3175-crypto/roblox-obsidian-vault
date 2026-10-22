---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Rarity communicates through more than color

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use a rarity word, frame motif, and silhouette treatment alongside hue.

## Implementation and rationale
Draft five tiers with distinct border shapes and concise labels. Preserve the object's silhouette; particle clouds should not obscure it. Show functional differences explicitly rather than implying a rare color guarantees higher power. Paid randomized tables require item-level probabilities, not just decorative rarity labels.

## Acceptance test
- [ ] Inspect grayscale screenshots and a low-effects mode. Testers can still distinguish tiers, and the shop never substitutes rarity categories for required final-outcome odds.

## Related decisions
- [[A reusable toy-box visual system]]
- [[Bright style without unreadable information]]
- [[Paid randomness decision gate]]
- [[Collectibles that read at a distance]]

## Sources
- [[REF - Accessibility guidelines]]
- [[REF - Paid random item guidelines]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
