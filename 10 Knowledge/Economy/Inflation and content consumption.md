---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Inflation and content consumption

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Inspect how quickly players exhaust meaningful goals rather than celebrating large currency balances.

## Implementation and rationale
Track median and upper-tail wallets by progression band and compare event cohorts with ordinary cohorts. A small group earning extreme values can invalidate the next update's economy. Correct formulas and sinks before adding arbitrary extra zeroes to every price. Do not wipe valid progress as a substitute for diagnosis.

## Acceptance test
- [ ] Replay a high-yield event scenario through the economy simulator and ask how many future upgrades it buys. Document expected effects before deploying balance changes.

## Related decisions
- [[Currency sources and sinks ledger]]
- [[Upgrade curves with readable payback]]
- [[Roll out economy changes with a return path]]
- [[Bounded multiplier stacking]]

## Sources
- [[REF - Balance virtual economies]]
- [[REF - LiveOps planning]]

Map: [[MOC - Economy]] · [[START HERE - Slop Game Lab]]
