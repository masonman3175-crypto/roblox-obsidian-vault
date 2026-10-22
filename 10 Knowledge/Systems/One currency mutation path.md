---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# One currency mutation path

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
All earning and spending should pass through a server service with a reason code.

## Implementation and rationale
Implement award and spend operations with finite, nonnegative, bounded amounts and a transaction identity when retries matter. Keep balance checks and debits together in the service. UI formatting must not alter the stored amount. Emit analytics only after the successful state operation, and tolerate analytics failure.

## Acceptance test
- [ ] Two simultaneous upgrade requests cannot both spend the same last coins. Invalid numeric values and negative prices are rejected rather than credited.

## Related decisions
- [[Currency sources and sinks ledger]]
- [[Upgrade curves with readable payback]]
- [[Intent-only network contracts]]
- [[Durable idempotent purchase grants]]

## Sources
- [[REF - Client-server boundary validation]]
- [[REF - Economy events]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
