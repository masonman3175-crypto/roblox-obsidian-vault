---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Catalog and content validation

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Reject broken content definitions before they become a player-facing shop or reward.

## Implementation and rationale
Validate unique keys, required fields, supported rarity, existing species references, nonnegative finite values, configured capacity, and valid grant kinds. Check every asset/preview reference and distinguish an unassigned placeholder from a real uploaded ID. Keep probabilities and runtime pricing metadata out of hand-authored duplicate UI strings. Produce actionable errors tied to exact rows.

## Acceptance test
- [ ] Supply fixtures with duplicate SKUs, missing models, invalid weights, negative costs, unknown grant handlers, and absent preview fallbacks. Each fails clearly before publication.

## Related decisions
- [[Many products through one catalog]]
- [[Data-driven content production]]
- [[Odds table as one source of truth]]
- [[Asset provenance and ownership ledger]]

## Sources
- [[REF - Properties and attributes]]
- [[REF - Paid random item guidelines]]
- [[REF - Developer products]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]
