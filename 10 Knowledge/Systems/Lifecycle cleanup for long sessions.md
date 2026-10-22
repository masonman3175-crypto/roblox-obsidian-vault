---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Lifecycle cleanup for long sessions

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Every recurring connection, spawned effect, and temporary object needs a teardown owner.

## Implementation and rationale
Use one lifecycle container per player or feature. Disconnect listeners when a panel or character is replaced. Pool only measured high-churn objects; pooling is not a substitute for clearing state. Bound queue sizes and historical data kept in memory. Track counts during repeated respawns and menu openings.

## Acceptance test
- [ ] Open and close menus 100 times, respawn repeatedly, and join/leave with multiple clients. Memory and active listener counts should stabilize rather than grow every cycle.

## Related decisions
- [[Rarity VFX within a budget]]
- [[Measured mobile performance budget]]
- [[UI state and viewport matrix]]
- [[Service boundaries for a coding robot]]

## Sources
- [[REF - Improve performance]]
- [[REF - MicroProfiler walkthrough]]

Map: [[MOC - Systems]] · [[START HERE - Slop Game Lab]]
