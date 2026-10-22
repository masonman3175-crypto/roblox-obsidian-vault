---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Prestige with an explicit contract

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
A prestige reset must state exactly what resets, what persists, and what the player receives.

## Implementation and rationale
Prototype resetting earned coins and temporary production upgrades while preserving collection discoveries, purchased cosmetics, settings, and durable entitlements. Show before-and-after projections and require an intentional confirmation. Keep prestige out of the first tutorial unless it is essential to understanding the loop.

## Acceptance test
- [ ] Cancel leaves state unchanged. Confirm applies the reset once. Crash/rejoin between confirmation and save cannot duplicate the prestige reward or erase permanent purchases.

## Related decisions
- [[Destructive actions need a preview]]
- [[Versioned player-data migrations]]
- [[Upgrade curves with readable payback]]
- [[Products are not all the same entitlement]]

## Sources
- [[REF - Core loops]]
- [[REF - Data stores]]

Map: [[MOC - Core Design]] · [[START HERE - Slop Game Lab]]
