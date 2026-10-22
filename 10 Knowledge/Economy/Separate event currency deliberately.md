---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Separate event currency deliberately

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
An event can use a bounded token earned through normal play to avoid flooding permanent coins.

## Implementation and rationale
Define earn rate, shop sinks, expiry or conversion rules, and handling for unspent tokens in advance. Do not allow a paid currency bridge to a randomized event reward without treating that as paid randomness. Keep event accounting separate from the permanent wallet and show expiry terms honestly.

## Acceptance test
- [ ] End an event while a player is offline, then rejoin. Unspent tokens follow the announced rule and cannot be duplicated by repeating the end-of-event conversion.

## Related decisions
- [[One event template with many themes]]
- [[Currency sources and sinks ledger]]
- [[Paid randomness decision gate]]
- [[Free and premium season tracks]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - LiveOps planning]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
