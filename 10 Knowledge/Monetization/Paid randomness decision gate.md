---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Paid randomness decision gate

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use direct, guaranteed products in the MVP; treat any later paid randomness as a separate feature with dedicated requirements.

## Implementation and rationale
Map every paid path, including coins purchasable with Robux, tickets, fusion inputs, and luck modifiers. If a paid path changes the random outcome, show final item outcomes and actual odds and apply player-specific eligibility. Free acquisition should be genuinely separate and clear. A rarity label alone is not an odds disclosure.

## Acceptance test
- [ ] Audit the complete currency graph, activate every probability modifier, and verify per-user restrictions on both UI and server. The percentages shown correspond to the table used to resolve the outcome.

## Related decisions
- [[Per-player product availability]]
- [[Odds table as one source of truth]]
- [[Temporary boosts have an explicit clock]]
- [[Trading is a later transaction system]]

## Sources
- [[REF - Paid random item guidelines]]
- [[REF - PolicyService API]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
