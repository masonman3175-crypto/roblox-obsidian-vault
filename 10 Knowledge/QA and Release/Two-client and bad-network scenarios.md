---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Two-client and bad-network scenarios

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Test race conditions and delayed responses in addition to solo happy paths.

## Implementation and rationale
Use multiple clients to compete for one snack, deposit into a final slot, join/leave during a public goal, and open menus during state updates. Add latency and packet-loss simulations where supported. Keep invariants separate from exact animation timing so legitimate network variation is tolerated.

## Acceptance test
- [ ] At the end of each run, count authoritative items and owners. There are no two owners for one instance, duplicate payouts, or permanent stuck reservations.

## Related decisions
- [[Collectible lifecycle state machine]]
- [[Spatial validation under latency]]
- [[UI snapshots and revisions]]
- [[Deposits must commit once]]

## Sources
- [[REF - Studio testing modes]]
- [[REF - Remote events and callbacks]]

Map: [[MOC - QA and Release]] · [[START HERE - Slop Game Lab]]
