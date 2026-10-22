---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Odds table as one source of truth

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Do not maintain separate shop text and reward-selection probabilities by hand.

## Implementation and rationale
Store item outcomes as integer weights, calculate percentages from the active table, and define rounding so the displayed final percentages total exactly 100. Show how modifiers alter the table before purchase. Keep the original table version on any transaction record that needs investigation. Avoid silently changing a pending paid outcome.

## Acceptance test
- [ ] Validate weight positivity, all item references, total percentages, modifier combinations, and restricted-user behavior. A statistical simulation is useful but does not replace checking the actual table logic.

## Related decisions
- [[Paid randomness decision gate]]
- [[Catalog and content validation]]
- [[Deterministic economy simulation]]
- [[Per-player product availability]]

## Sources
- [[REF - Paid random item guidelines]]
- [[REF - Balance virtual economies]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
