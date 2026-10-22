---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Bounded multiplier stacking

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Document the order of operations and cap rules for every boost.

## Implementation and rationale
A draft formula might multiply base production by prestige and an active boost, then apply a bounded additive event bonus. Do not silently compound every product and weekend bonus without a ceiling. Show base and boosted values separately. Prefer convenience and cosmetic value over selling runaway power that makes old zones meaningless.

## Acceptance test
- [ ] Test no boost, each boost alone, every combination, expired boost, and reconnect. Results match the documented formula and never become NaN, infinity, or negative.

## Related decisions
- [[Upgrade curves with readable payback]]
- [[Temporary boosts have an explicit clock]]
- [[Separate event currency deliberately]]
- [[Deterministic economy simulation]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
