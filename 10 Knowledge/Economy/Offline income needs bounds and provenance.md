---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Offline income needs bounds and provenance

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
If offline earnings are included, make them a server-calculated catch-up reward, not client-reported elapsed time.

## Implementation and rationale
Use the last durable timestamp and configured cap; avoid negative durations and treat implausible future dates conservatively. State exactly which production sources count while absent. Do not make a paid offline upgrade necessary for normal progress. Store a claim identity or timestamp so repeated joins cannot replay the same reward.

## Acceptance test
- [ ] Change the test client clock, reconnect repeatedly, and simulate a long absence. Only eligible elapsed server time is paid, and the cap is visible to the player.

## Related decisions
- [[Persistence is part of gameplay]]
- [[Currency sources and sinks ledger]]
- [[Inflation and content consumption]]
- [[Deterministic economy simulation]]

## Sources
- [[REF - Data stores]]
- [[REF - Client-server boundary validation]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
