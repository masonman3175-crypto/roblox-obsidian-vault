---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Server time for real deadlines

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Every countdown should represent a real server-defined schedule and end when it says it ends.

## Implementation and rationale
Store absolute event end times and render remaining time locally from a synchronized estimate. Handle delayed joins and expired content consistently. Do not restart a shop discount timer each session. Separate a gameplay cycle such as a guardian patrol from a real-world product availability deadline.

## Acceptance test
- [ ] Change the local clock and reconnect at an event boundary. The server remains authoritative and an expired offer is not purchasable through a stale client screen.

## Related decisions
- [[One event template with many themes]]
- [[Separate event currency deliberately]]
- [[Runtime prices not painted prices]]
- [[Offer placement without modal spam]]

## Sources
- [[REF - Monetization overview]]
- [[REF - LiveOps planning]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
