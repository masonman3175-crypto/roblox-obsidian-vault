---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Many products through one catalog

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A broad catalog should create variety in expression, not dozens of bespoke purchase scripts.

## Implementation and rationale
Use one schema for sku, product kind, external product ID, preview, description, duration, grant payload, and availability. Group cosmetic skins, base themes, trails, emotes, and convenience into clear categories. Begin with a few products to verify fulfilment, then scale content through data. Draft prices are experiment inputs, never copied competitor economics.

## Acceptance test
- [ ] Every displayed product maps to exactly one grant definition, has a useful fallback preview, and can be disabled without publishing a broken card.

## Related decisions
- [[Shop browsing before checkout]]
- [[Durable idempotent purchase grants]]
- [[Products are not all the same entitlement]]
- [[Cosmetics can carry catalog breadth]]

## Sources
- [[REF - Developer products]]
- [[REF - Monetization foundations]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
