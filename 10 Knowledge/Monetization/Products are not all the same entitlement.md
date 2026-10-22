---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Products are not all the same entitlement

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Distinguish permanent pass ownership, durable cosmetic unlocks, consumable quantity, subscription access, and season-specific upgrades.

## Implementation and rationale
A product catalog chooses the grant type. A player profile stores game-owned grants, while platform-owned benefits require their documented ownership or subscription checks. An owned item needs a restore/reconciliation path rather than another buy button. Do not assume every product uses a developer-product receipt.

## Acceptance test
- [ ] Test returning owners, an expired subscription, an already-owned pass, a consumed boost, and an archived season. Each card shows the correct status and purchase behavior.

## Related decisions
- [[Many products through one catalog]]
- [[Durable idempotent purchase grants]]
- [[Recurring value needs recurring production]]
- [[Free and premium season tracks]]

## Sources
- [[REF - Passes]]
- [[REF - Subscriptions]]
- [[REF - Player data and purchasing systems]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
