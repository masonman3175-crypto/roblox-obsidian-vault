---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Achievements recognize mastery

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Use achievements to recognize a clear accomplishment rather than a purchase or an arbitrary endless grind.

## Implementation and rationale
Draft milestones such as first successful delivery, discovery of every family in a zone, a difficult no-loss route, or a cooperative rescue. Keep the exact objective visible. In-game claim tracking and platform badge granting are separate operations that may need retry handling. Do not let badge-service failure undo valid gameplay progress.

## Acceptance test
- [ ] Complete a milestone, rejoin, and retry the grant after a simulated service failure. The achievement remains earned and its reward cannot be duplicated.

## Related decisions
- [[Collection as a goal system]]
- [[Quests that use existing actions]]
- [[Purchase and progress support records]]
- [[Persistence is part of gameplay]]

## Sources
- [[REF - Badges]]
- [[REF - Introduction to quest design]]

Map: [[MOC - LiveOps]] · [[START HERE - Slop Game Lab]]
