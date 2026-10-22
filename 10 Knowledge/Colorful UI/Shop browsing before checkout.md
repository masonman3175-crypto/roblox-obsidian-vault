---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Shop browsing before checkout

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Organize a large catalog into a few clear categories rather than covering the HUD in offers.

## Implementation and rationale
Prototype tabs for Cosmetics, Convenience, Bundles, and Owned. Each card shows a preview, exact benefit, duration, ownership state, and current price. Selecting a card opens details, not checkout. A dedicated buy action then invokes the platform prompt. Keep earned-currency purchases visually distinct from Robux purchases.

## Acceptance test
- [ ] A tester can name whether a product is permanent, consumable, or recurring before buying. A cancelled platform prompt returns to the same useful details screen.

## Related decisions
- [[Purchase flow is a state machine]]
- [[Many products through one catalog]]
- [[Runtime prices not painted prices]]
- [[Offer placement without modal spam]]

## Sources
- [[REF - Monetization foundations]]
- [[REF - Contextual purchases]]
- [[REF - Monetization overview]]

Map: [[MOC - Colorful UI]] · [[START HERE - Slop Game Lab]]
