---
research_pack: slop-lab-v2
kind: guide
status: design-proposal
created: 2026-10-17
tags: [roblox, knowledge]
---

# Free and premium season tracks

> [!note] Evidence boundary
> This is an original implementation/design proposal. Sources below supply background or API guidance; proposed timings, quantities, and business results are not established facts.

## Decision
Show the full reward schedule and manageable objectives before offering the premium upgrade.

## Implementation and rationale
Draft a small season using delivery, discovery, and cooperative objectives already supported by the game. Clearly identify free rewards, premium rewards, claimed states, and the actual end date. Store season ID with progress and purchase grants. Define late purchase, missed claims, and end-of-season handling explicitly.

## Acceptance test
- [ ] Simulate buying the premium track near the end, reconnecting, and claiming past earned tiers. Each eligible tier grants once, and no expired purchase offers an unavailable reward.

## Related decisions
- [[Quests that use existing actions]]
- [[Separate event currency deliberately]]
- [[Products are not all the same entitlement]]
- [[A sustainable release calendar]]

## Sources
- [[REF - Season pass design]]
- [[REF - Monetization foundations]]

Map: [[MOC - Monetization]] · [[START HERE - Slop Game Lab]]
