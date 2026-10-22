---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Runtime prices not painted prices

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
The price on the shop card should match the platform prompt for that player.

## Implementation and rationale
Read current product information with the documented client-side path and the correct product type. Keep prices out of static image artwork. Show a recoverable unavailable state when pricing fails rather than a guessed cheap price. If gifting or trading is later added, review regional-price transfer rules and arbitrage protection.

## Acceptance test
- [ ] Use the platform's dynamic-price testing tools in a test experience. Compare card and prompt, then repeat after a refresh, unavailable product, and price change.

## Related decisions
- [[Shop browsing before checkout]]
- [[Purchase flow is a state machine]]
- [[Trading is a later transaction system]]
- [[Many products through one catalog]]

## Sources
- [[REF - Regional pricing]]
- [[REF - Price optimization]]
- [[REF - MarketplaceService API]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
