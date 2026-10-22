---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# One event template with many themes

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Create a repeatable event definition instead of a custom global script for every holiday.

## Implementation and rationale
A definition includes stable event ID, server start/end timestamps, allowed zones, objectives, token sources, shop stock, and recovery rules. Start with a harmless delivery remix, not a server-wide economy multiplier plus several unrelated new systems. Use original seasonal themes without assuming every audience celebrates the same holiday.

## Acceptance test
- [ ] Join before, during, and after the event and reconnect at the boundary. The UI and server agree on eligibility and remaining time, including already-earned claims.

## Related decisions
- [[Separate event currency deliberately]]
- [[A sustainable release calendar]]
- [[Server time for real deadlines]]
- [[Free and premium season tracks]]

## Sources
- [[REF - LiveOps planning]]
- [[REF - Content updates]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
